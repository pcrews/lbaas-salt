#-----------
# imports
#-----------
import os
import ast
import sys
import json
import struct
import random
import shutil
import hashlib
import logging
import argparse
import commands
import requests

from Crypto.Cipher import AES
from swiftclient import Connection, ClientException
from time import gmtime, strftime

#------------------
# utility functions
#------------------
def md5_for_file(filename, block_size=2 ** 20):
    with open(filename, 'rb') as fh:
        md5 = hashlib.md5()
        while True:
            data = fh.read(block_size)
            if not data:
                break
            md5.update(data)
    return md5.hexdigest()

def encrypt_file(key, in_filename, out_filename=None, chunksize=64 * 1024):
    """
        http://eli.thegreenplace.net/2010/06/25/ \
        aes-encryption-of-files-in-python-with-pycrypto/

        Encrypts a file using AES (CBC mode) with the
        given key.

        key:
            The encryption key - a string that must be
            either 16, 24 or 32 bytes long. Longer keys
            are more secure.

        in_filename:
            Name of the input file

        out_filename:
            If None, '<in_filename>.enc' will be used.

        chunksize:
            Sets the size of the chunk which the function
            uses to read and encrypt the file. Larger chunk
            sizes can be faster for some files and machines.
            chunksize must be divisible by 16.
    """
    if not out_filename:
        out_filename = in_filename + '.enc'

    iv = ''.join(chr(random.randint(0, 0xFF)) for i in range(16))
    encryptor = AES.new(key, AES.MODE_CBC, iv)
    filesize = os.path.getsize(in_filename)

    with open(in_filename, 'rb') as infile:
        with open(out_filename, 'wb') as outfile:
            outfile.write(struct.pack('<Q', filesize))
            outfile.write(iv)

            while True:
                chunk = infile.read(chunksize)
                if len(chunk) == 0:
                    break
                elif len(chunk) % 16 != 0:
                    chunk += ' ' * (16 - len(chunk) % 16)

                outfile.write(encryptor.encrypt(chunk))


def decrypt_file(key, in_filename, out_filename=None, chunksize=24 * 1024):
    """ Decrypts a file using AES (CBC mode) with the
        given key. Parameters are similar to encrypt_file,
        with one difference: out_filename, if not supplied
        will be in_filename without its last extension
        (i.e. if in_filename is 'aaa.zip.enc' then
        out_filename will be 'aaa.zip')
    """
    if not out_filename:
        out_filename = os.path.splitext(in_filename)[0]

    with open(in_filename, 'rb') as infile:
        origsize = struct.unpack('<Q', infile.read(struct.calcsize('Q')))[0]
        iv = infile.read(16)
        decryptor = AES.new(key, AES.MODE_CBC, iv)

        with open(out_filename, 'wb') as outfile:
            while True:
                chunk = infile.read(chunksize)
                if len(chunk) == 0:
                    break
                outfile.write(decryptor.decrypt(chunk))

            outfile.truncate(origsize)


def backup_database(args):
    """ Backup our database via innobackupex """

    print "Creating backup up of MySQL database via innobackupex..."
    backup_path = None
    cmd = 'innobackupex %s' %args.dbbackuppath
    status, output = commands.getstatusoutput(cmd) 
    print "Command: %s" %cmd
    print "Status: %s" %status
    print "Output:\n%s" %output
    for line in output.split('\n'):
        if line.strip().startswith('innobackupex: Backup created in directory'):
            backup_path = line.split('directory')[1].strip().replace("'",'')
    print "Backup directory: %s" %backup_path
    full_backup_path = os.path.join(args.dbbackuppath, backup_path)
    # apply log
    print "Preparing backup in directory: %s..." %backup_path
    cmd = 'innobackupex --apply-log --use-memory=1G %s' %(full_backup_path)
    status, output = commands.getstatusoutput(cmd) 
    print "Command: %s" %cmd
    print "Status: %s" %status
    print "Output:\n%s" %output
    # create tarball from directory
    print "Creating tarball from backup: %s" %backup_path
    os.chdir(args.dbbackuppath)
    datetime_info = strftime("%Y%m%d-%H-%M-%S", gmtime())
    backup_name = "%s-%s.tar.gz" %(args.backupname, datetime_info)
    print "Backup tarball: %s" %backup_name
    cmd = "tar -cvzf %s %s" %(backup_name, os.path.basename(backup_path))
    status, output = commands.getstatusoutput(cmd) 
    print "Command: %s" %cmd
    print "Status: %s" %status
    print "Output:\n%s" %output
    # encrypt tarball
    encrypted_backup = backup_name + '.enc'
    encrypt_key = hashlib.sha256(args.encryptkey).digest()
    encrypt_file(encrypt_key, backup_name, encrypted_backup)
    # cleanup
    print "Removing backup directory: %s..." %full_backup_path
    shutil.rmtree(full_backup_path)
    print "Removing unencrypted backup tarball: %s..." %backup_name
    os.remove(backup_name)
    return encrypted_backup

def tar_directory(args):
    """ create a tarball for the specified """

    print "Creating tarball from backup: %s" %args.backupdirectory
    os.chdir(os.path.dirname(args.backupdirectory))
    datetime_info = strftime("%Y%m%d-%H-%M-%S", gmtime())
    backup_name = "%s-%s.tar.gz" %(args.backupname, datetime_info)
    print "Backup tarball: %s" %backup_name
    cmd = "tar -cvzf %s %s" %(backup_name, os.path.basename(args.backupdirectory))
    status, output = commands.getstatusoutput(cmd) 
    print "Command: %s" %cmd
    print "Status: %s" %status
    print "Output:\n%s" %output
    # encrypt tarball
    encrypted_backup = backup_name + '.enc'
    encrypt_key = hashlib.sha256(args.encryptkey).digest()
    encrypt_file(encrypt_key, backup_name, encrypted_backup)
    # cleanup
    print "Removing unencrypted backup tarball: %s..." %backup_name
    os.remove(backup_name)
    return encrypted_backup

def get_auth_and_endpoint(args, service_name="Object Storage"):
    """ Get our keystone auth token to work with the api server """
    request_data = {'auth':{ 'tenantName': args.ostenantname
                           , 'passwordCredentials':{'username': args.osusername
                                                   , 'password': args.ospassword}
                           }
                   }
    auth_url = args.osauthurl
    if not auth_url.endswith('tokens'):
        auth_url = os.path.join(auth_url, 'tokens')
    request_data = json.dumps(request_data)
    headers = {"Content-Type": "application/json"}
    request_result = requests.post(auth_url, data=request_data, headers=headers, verify=False)
    request_data = ast.literal_eval(request_result.text)
    auth_token = request_data['access']['token']['id']
    for service in request_data['access']['serviceCatalog']:
        if service['name'] == 'Object Storage':
            endpoint = service['endpoints'][0]['publicURL'].replace('\\','')
    return auth_token, endpoint

def upload_file(args, auth_token, endpoint, backup_file):
    # you must set headers this way
    headers = {"Content-Type": 'application/gzip'}
    backup_file_path = os.path.join(os.getcwd(),backup_file)
    print 'Backup name: %s' %backup_file

    # length
    content_length = os.stat(backup_file_path).st_size
    print 'Backup Length: %s' %content_length
    
    # checksum
    file_md5 = md5_for_file(backup_file_path)
    print 'Backup MD5: %s' %file_md5
    auth_url = args.osauthurl
    if auth_url.endswith('tokens'):
        auth_url = os.path.dirname(auth_url)
    try:
    # establish connection
        conn = Connection(auth_url,
                          args.osusername,
                          args.ospassword,
                          tenant_name=args.ostenantname,
                          auth_version="2.0")
    except ClientException, err:
        print "No Swift Connection: %s", str(err)
    # upload object
    try:
        with open(backup_file_path, 'rb') as file_handle:
            conn.put_object(args.swiftstorename,
                            backup_file,
                            file_handle,
                            headers=headers,
                            content_length=content_length,
                            etag=file_md5)
    except ClientException, err:
        print 'Upload failed: %s', str(err)
    else:
        print 'Upload succeeded'

    # list our objects in the store
    print "Listing all objects in store..."
    base_url = os.path.join(endpoint, args.swiftstorename)
    auth_headers = {"X-Auth-Token": "%s" %(auth_token)}
    result = requests.get(base_url, headers=auth_headers)
    for line in result.text.split('\n'):
        print line

##########
# parser
##########
parser = argparse.ArgumentParser(description='backup_and_restore_directory.py Utility script to tar, encrypt and upload directories to Swift or to do the same for MySQL servers via xtrabackup')
parser.add_argument( '--verbose'
                   , action = 'count'
                   , dest = 'verbose'
                   , default = 0
                   , help = 'Controls internal output.  Utilize multiple times to increase output'
                   )
parser.add_argument( '--os_username'
                   , action = 'store'
                   , dest ='osusername'
                   , default = None
                   , help = 'OpenStack username to use for testing.'
                   )
parser.add_argument( '--os_password'
                   , action = 'store'
                   , dest = 'ospassword'
                   , default = None
                   , help = 'OpenStack password for os-username'
                   )
parser.add_argument( '--os_tenant_name'
                   , action = 'store'
                   , dest = 'ostenantname'
                   , default = None
                   , help = 'OpenStack tenant name'
                   )
parser.add_argument( '--os_auth_url'
                   , action = 'store'
                   , dest = 'osauthurl'
                   , default = 'https://region-a.geo-1.identity.hpcloudsvc.com:35357/v2.0/tokens'
                   , help = 'OpenStack auth url (keystone endpoint)'
                   )
parser.add_argument( '--swift_store_name'
                   , action = 'store'
                   , dest = 'swiftstorename'
                   , default = None
                   , help = 'Name of the container to use for storage'
                   )
parser.add_argument( '--backup_name'
                   , action = 'store'
                   , dest = 'backupname'
                   , default = None
                   , help = 'Used for naming the backup tarball / what will be stored in Swift.  names are backup_name-YY-MM-DD-HH:mm:ss.tar.gz'
                   )
parser.add_argument( '--directory'
                   , action = 'store'
                   , dest = 'backupdirectory'
                   , default = None
                   , help = 'the directory to tar, backup, and store'
                   )
parser.add_argument( '--encrypt_key'
                   , action = 'store'
                   , dest = 'encryptkey'
                   , default = None
                   , help = 'the password to use as a base for the encryption key'
                   )
parser.add_argument( '--db_backup_path'
                   , action = 'store'
                   , dest = 'dbbackuppath'
                   , default = None
                   , help = 'path to use for MySQL backups'
                   )

#-------
# main 
#-------
 
args = parser.parse_args(sys.argv[1:])
if args.verbose:
    print "VERBOSE: argument values:"
    for key, item in vars(args).items():
        print "VERBOSE: %s || %s" %(key, item)

if args.dbbackuppath:
    # backup the database / get a tarball back for upload
    backup_file = backup_database(args)
else:
    # tarball the directory for backup
    backup_file = tar_directory(args)

# store the backup
auth_token, endpoint = get_auth_and_endpoint(args)
upload_file(args, auth_token, endpoint, backup_file)

# remove the backup file from the server
print "Removing backup file: %s" %backup_file
os.remove(backup_file)

