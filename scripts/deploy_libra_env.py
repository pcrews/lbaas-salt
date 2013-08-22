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

# test nodes

# update pillar

# call highstate
cmd = "sudo salt *galera* state.highstate"
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



