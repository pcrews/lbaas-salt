# deploy_libra.py
# script for the magic of deploying a libra environment
# we take in a yaml

###########
# imports
###########
import os
import ast
import sys
import time
import yaml
import logging
import argparse
import commands

from time import gmtime, strftime

##########
# parser
##########
parser = argparse.ArgumentParser(description='deploy_libra.py - we spin the libra magicks')
parser.add_argument( '--verbose'
                   , action = 'count'
                   , dest = 'verbose'
                   , default = 0
                   , help = 'Controls internal output.  Utilize multiple times to increase output'
                   )
parser.add_argument( '--config'
                   , action = 'store'
                   , dest ='configfile'
                   , default = 'deploylibra.cfg'
                   , help = 'path to a config file containing options.  Command line options will supercede any options specified in the config'
                   )
parser.add_argument( '--salt-cloud-config'
                   , action = 'store'
                   , dest = 'saltcloudconfigfile'
                   , default = None
                   , help = 'Path to a salt-cloud config file'
                   )
parser.add_argument( '--salt-cloud-map'
                   , action = 'store'
                   , dest = 'saltcloudmapfile'
                   , default = None
                   , help = 'Path to a salt-cloud map file to use in conjunction with the config file'
                   )
parser.add_argument( '--cleanup'
                   , action = 'store_true'
                   , dest = 'cleanup'
                   , default = False
                   , help = 'flag to toggle deletion of the salt-cloud created vms once complete'
                   )
parser.add_argument( '--os_user'
                   , action = 'store'
                   , dest ='osuser'
                   , default = None
                   , help = 'OpenStack username for the account that will own the deployment.'
                   )
parser.add_argument( '--os_tenant'
                   , action = 'store'
                   , dest ='ostenant'
                   , default = None
                   , help = 'OpenStack tenant name for the account that will own the deployment.'
                   )
parser.add_argument( '--os_password'
                   , action = 'store'
                   , dest ='ospassword'
                   , default = None
                   , help = 'OpenStack password for the account that will own the deployment.'
                   )
parser.add_argument( '--os_region'
                   , action = 'store'
                   , dest ='osregion'
                   , default = None
                   , help = 'OpenStack region for deployment'
                   )
parser.add_argument( '--os_auth_url'
                   , action = 'store'
                   , dest ='osauthurl'
                   , default = None
                   , help = 'OpenStack auth url'
                   )

######
# main
######
# configure logging
logging.basicConfig(format='%(asctime)s %(message)s', datefmt='%Y%m%d-%H%M%S %p', level=logging.INFO)

args = parser.parse_args(sys.argv[1:])
if args.verbose:
    logging.info("argument values:")
    for key, item in vars(args).items():
        logging.info("\t%s: %s" %(key, item))

logging.info("Updating environment vars w/ openstack credentials...")
os_values = { 'OS_USERNAME':args.osuser
            , 'OS_TENANT_NAME': args.ostenant
            , 'OS_PASSWORD': args.ospassword
            , 'OS_AUTH_URL': args.osauthurl
            , 'OS_REGION_NAME': args.osregion
            }
for key, value in os_values:
    os.environ[key]=value
            
"""
if args.configfile:
    # We have a magic config file that we expect to be in key: value format
    # get our test input variants (nodes, names, etc)
    inputs_file = open(args.configfile,'r')
    deploylibra_inputs = yaml.load(inputs_file)
    inputs_file.close()

print deploylibra_inputs
"""

print "Welcome to deploy_libra, where we make all your wildest dreams come true..."
time.sleep(.5)
print "Provided your wildest dreams involve setting up a libra lbaas environment in HP Cloud via salt..."
print "Now on to business..."
#sys.exit(0)
# call salt-cloud
salt_cloud_create_cmd = "salt-cloud -C %s -m %s -y" %(args.saltcloudconfigfile, args.saltcloudmapfile)
retcode, result = commands.getstatusoutput(salt_cloud_create_cmd)

logging.info(salt_cloud_create_cmd)
logging.info(retcode)
logging.info(result)

# gather ips + names
lbaas_vms = {}
name_next = False
ip_next = False
node_name = None
for line in result.split('\n'):
    print line
    if line.strip().startswith('name:'):
        name_next=True
    elif name_next:
        node_name = line.strip()
        lbaas_vms[node_name]=''
        name_next=False
    elif line.strip().startswith('public_ips:'):
        ip_next = True
    elif ip_next:
        lbaas_vms[node_name] = line.replace('-','').strip()
        node_name = None
        ip_next = False

print "Libra infrastructure nodes:"
for key, item in lbaas_vms.items():
   print '    %s: %s' %(key, item)

# update pillar
print "Updating pillar data and updating nodes' pillars..."
pillar_file = '/srv/lbaas-staging-pillar/bootstrap_pillar.sls'
with open(pillar_file,'a') as outfile:
    for key, item in lbaas_vms.items():
        # This is a bit bobo - we just cheat and repeat servers
        # until we have proper logic for controlling / detecting infrastructure
        # that handles this as it should
        pillar_name = key.replace('-','_').replace('-stage','')
        if 'api' in key:
            for i in range(3):
                pillar_name = 'lbaas_api_%d' %(i+1)
                outfile.write("%s: %s\n" %(pillar_name,item))
                outfile.write("%s_floating_ip: %s\n" %(pillar_name, item))
        elif 'pool' in key:
            outfile.write("lbaas_pool_mgm_1: %s\n" %(item))
        elif 'galera' in key:
            for i in range(3):
                pillar_name = 'lbaas_galera_%d' %(i+1)
                outfile.write("%s: %s\n" %(pillar_name,item))
            outfile.write("lbaas_galera_cluster_address: gcomm:// \n")
            outfile.write("lbaas_galera_wsrep_node_address: %s\n" %item)
        elif 'gearman' in key:
            for i in range(2):
                pillar_name = 'lbaas_gearman%d' %(i+1)
                outfile.write("%s: %s\n" %(pillar_name,item))
                outfile.write("%s_floating_ip: %s\n" %(pillar_name, item))

# restart salt-master:
cmd = "sudo service salt-master restart"
retcode, result = commands.getstatusoutput(cmd)
logging.info(cmd)
logging.info(retcode)
logging.info(result)

# create haproxy image
logging.info("Salting haproxy worker base image...")
cmd = "sudo salt *haproxy* state.highstate"
retcode, result = commands.getstatusoutput(cmd)
logging.info(cmd)
logging.info(retcode)
logging.info(result)

logging.info("calling sync on haproxy worker base image...")
cmd = "sudo salt *haproxy* cmd.run 'sync'"
retcode, result = commands.getstatusoutput(cmd)
logging.info(cmd)
logging.info(retcode)
logging.info(result)

logging.info("calling 'nova image' on haproxy worker base image...")
print "Finding nova id for haproxy image"
cmd = 'nova list | grep haproxy'
status, output = commands.getstatusoutput(cmd)
logging.info(cmd)
logging.info(retcode)
logging.info(output)
output = output.split('\n')
nova_id = output[0].split('|')[1]
logging.info( 'Nova id: %s' %nova_id)
logging.info( '#'*80)
logging.info("Creating nova image from Nova instance: %s" %(nova_id))

image_id = None
date_info = strftime("%Y%m%d-%H%M%S", gmtime())
image_name = "lbaas-stage-haproxy-%s" %(date_info)
logging.info("Image name: %s" %image_name)
cmd = 'nova image-create %s %s' %(nova_id, image_name)
status, output = commands.getstatusoutput(cmd)
logging.info(cmd)
logging.info(retcode)
logging.info(output)

save_done = False
attempts_remaining = 30
sleep_time = 3
while not save_done and attempts_remaining:
    attempts_remaining -= 1
    cmd = 'nova image-list | grep %s' %(image_name)
    status, output = commands.getstatusoutput(cmd)
    output_data = output.split('\n')[0].split('|')
    if output_data[3].strip() == 'ACTIVE':
        save_done = True
        logging.info(cmd)
        logging.info(retcode)
        logging.info(output)
        image_id = output_data[1]
    else:
        logging.info("Waiting for image save to finish...")
        time.sleep(sleep_time)

cmd = 'nova list | grep haproxy'
status, output = commands.getstatusoutput(cmd)
logging.info(cmd)
logging.info(retcode)
logging.info(output)

logging.info('')
logging.info('='*80)
logging.info('IMAGE_ID: %s' %image_id)
logging.info('='*80)
logging.info('')
time.sleep(10)

logging.info("updating saltmaster pillar...")
with open(pillar_file,'a') as outfile:
    outfile.write('lbaas-nodes-image-id: %s\n' %image_id)

# call highstate on remaining nodes
logging.info("Salting remaining servers...")
servers = ['galera','gearman','pool']
for servername in servers:
    logging.info("Salting %s server(s)..." %servername)
    cmd = "sudo salt *%s* state.highstate" %servername
    retcode, result = commands.getstatusoutput(cmd)
    logging.info(cmd)
    logging.info(retcode)
    logging.info(result)


# cleanup
if args.cleanup==True:
    delete_cmd = salt_cloud_create_cmd + ' -d'
    retcode, result = commands.getstatusoutput(delete_cmd)
    logging.info(delete_cmd)
    logging.info(retcode)
    logging.info(result)



