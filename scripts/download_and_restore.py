#-----------
# imports
#-----------
import os
import ast
import sys
import json
import struct
import logging
import argparse
import shutil
import commands
import requests
import hashlib

from Crypto.Cipher import AES
from swiftclient import Connection, ClientException
from time import gmtime, strftime

#------------------
# utility functions
#------------------
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

def untar_directory(args, tarball_name):
    """ untar / decrypt the tarball """

    print "Decrypting / decompressing encrypted tarball: %s " %tarball_name
    decrypted_tarball = tarball_name.replace('.enc','')
    encrypt_key = hashlib.sha256(args.encryptkey).digest()
    decrypt_file(encrypt_key, tarball_name, out_filename=decrypted_tarball, chunksize=24 * 1024)
    print "Decrypted tarball: %s" %decrypted_tarball
    cmd = 'tar xvzf %s' %decrypted_tarball
    status, output = commands.getstatusoutput(cmd) 
    print "Command: %s" %cmd
    print "Status: %s" %status
    print "Output:\n%s" %output
    untarred_dir = output.split('\n')[0]
    print "Untarred directory: %s" %untarred_dir
    return decrypted_tarball, untarred_dir

def get_auth_and_endpoint(args, service_name="Object Storage"):
    """ Get our keystone auth token to work with the api server """
    request_data = {'auth':{ 'tenantName': args.ostenantname
                           , 'passwordCredentials':{'username': args.osusername
                                                   , 'password': args.ospassword}
                           }
                   }
    request_data = json.dumps(request_data)
    headers = {"Content-Type": "application/json"}
    auth_url = args.osauthurl
    if not auth_url.endswith('tokens'):
        auth_url = os.path.join(auth_url, 'tokens')
    request_result = requests.post(auth_url, data=request_data, headers=headers, verify=False)
    request_data = ast.literal_eval(request_result.text)
    auth_token = request_data['access']['token']['id']
    for service in request_data['access']['serviceCatalog']:
        if service['name'] == 'Object Storage':
            endpoint = service['endpoints'][0]['publicURL'].replace('\\','')
    return auth_token, endpoint

def download_file(args, auth_token, endpoint, desired_backup=None):
    """ Download the desired (default=latest by timestamp) file from Swift """

    headers = {"X-Auth-Token": "%s" %(auth_token)}
    # list our objects in the store
    print "Listing all objects in store..."
    base_url = os.path.join(endpoint, args.swiftstorename)
    result = requests.get(base_url, headers=headers)
    swift_data = result.text.split('\n')
    for line in swift_data:
        print line
    swift_data.sort()
    if not desired_backup:
        desired_backup=swift_data[-1]
    print "Using backup: %s" %desired_backup

    object_url = os.path.join(endpoint, args.swiftstorename, desired_backup)
    try:
    # establish connection
        conn = Connection(args.osauthurl,
                          args.osusername,
                          args.ospassword,
                          tenant_name=args.ostenantname,
                          auth_version="2.0")
    except ClientException, err:
        print "No Swift Connection: %s", str(err)
    try:
        headers, body = conn.get_object(args.swiftstorename,
                                        desired_backup,
                                        resp_chunk_size=65536)
    except ClientException, err:
        print 'Download failed: %s', str(err)
    else:
        print 'Download succeeded'
    print headers
    print body
    print '#'*80
    s_etag = headers.get('etag')
    md5 = hashlib.md5()
    outfile = open(desired_backup, 'wb')
    read_length = 0
    for chunk in body:
        outfile.write(chunk)
        read_length += len(chunk)
        print "read_length: %d" % read_length
        if md5:
            md5.update(chunk)
    outfile.close()
    f_etag = md5.hexdigest()
    # need to figure out how to handle this
    if (s_etag != f_etag):
        print "MD5 for file from swift doesn't match that which was downloaded!"
        print "%s != %s" % (s_etag, f_etag)
    return desired_backup




##########
# parser
##########
parser = argparse.ArgumentParser(description='download_and_restore.py - utility script to download encrypted tarballs from Swift and to decrypt / untar them for use')
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
parser.add_argument( '--restore_dir'
                   , action = 'store'
                   , dest = 'restoredir'
                   , default = '/mnt/mysql_backups'
                   , help = 'path to use for downloading / untarring / working with MySQL backups'
                   )
parser.add_argument( '--datadir'
                   , action = 'store'
                   , dest = 'datadir'
                   , default = '/var/lib/mysql'
                   , help = 'path to use for downloading / untarring / working with MySQL backups'
                   )


#-------
# main 
#------- 
args = parser.parse_args(sys.argv[1:])
if args.verbose:
    print "VERBOSE: argument values:"
    for key, item in vars(args).items():
        print "VERBOSE: %s || %s" %(key, item)

restore_dir = args.restoredir
print "Using restore directory: %s" %restore_dir
os.chdir(restore_dir)


# retrieve the backup
auth_token, endpoint = get_auth_and_endpoint(args)
backup_tarball = download_file(args, auth_token, endpoint)

# untar it
decrypted_tarball, untarred_directory = untar_directory(args, backup_tarball)

# restore it
print "Copying files from backup directory: %s to datadir: %s" %(untarred_directory, args.datadir)
shutil.copytree(untarred_directory, args.datadir)

# cleanup the backup
print "Removing backup tarball: %s..." %(backup_tarball)
os.remove(backup_tarball)
print "Removing decrypted tarball: %s..." %(decrypted_tarball)
os.remove(decrypted_tarball)
print "Removing untarred directory: %s..." %(untarred_directory)
shutil.rmtree(untarred_directory)
