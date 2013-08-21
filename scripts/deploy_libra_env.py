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
salt_cloud_create_cmd = "salt-cloud -C %s -m %s -y"
retcode, result = commands.getstatusoutput(salt_cloud_create_cmd)

logging.info(salt_cloud_create_cmd)
logging.info(retcode)
logging.info(result)

# gather ips + names
for line in result.split('\n'):
    print line
    print '-' *80
    print

# update pillar

# test nodes

# update pillar

# call highstate

# cleanup
if args.cleanup=True:
    delete_cmd = salt_cloud_create_cmd + ' -d'
    retcode, result = commands.getstatusoutput(cmd)
    logging.info(cmd)
    logging.info(retcode)
    logging.info(result)



