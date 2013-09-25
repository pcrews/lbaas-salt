import os
import sys
import commands
import unittest

class testMySQLBackupRestore(unittest.TestCase):
    def testRestore(self):
        # NOTE: we don't use setUp as we want to ensure we try to wipe the vm
        # if we had machine creation in setUp, tearDown might not run...
        self.vm_name = os.environ['TEST_MINION_NAME']
        self.config_file = "/etc/salt/cloud.lbaas_tools_az2"
        self.profile_name = "hp_az2_large"
        # create test vm
        print "Creating test vm: %s..." %self.vm_name
        cmd = "sudo salt-cloud -C %s -p %s %s " %(self.config_file, self.profile_name, self.vm_name)
        status, output = commands.getstatusoutput(cmd)
        print "Command: %s" %(cmd)
        print "Status: %s" %(status)
        print "Output:\n%s" %(output)
        self.assertEqual(status, 0, msg=("Command: %s failed" %cmd))

        # test our vm
        print "Pinging vm..."
        cmd = "sudo salt %s test.ping" %(self.vm_name)
        status, output = commands.getstatusoutput(cmd)
        print "Command: %s" %(cmd)
        print "Status: %s" %(status)
        print "Output:\n%s" %(output)
        self.assertEqual(status, 0, msg=("Command: %s failed" %cmd))

        # highstate the machine
        cmd = "sudo salt %s state.highstate" %(self.vm_name)
        status, output = commands.getstatusoutput(cmd)
        print "Command: %s" %(cmd)
        print "Status: %s" %(status)
        print "Output:\n%s" %(output)
        self.assertEqual(status, 0, msg=("Command: %s failed" %cmd))

        # stop mysql so we can restore
        print "Stopping mysql server for restore..."
        cmd = "sudo salt %s cmd.run 'service mysql stop'" %(self.vm_name)
        status, output = commands.getstatusoutput(cmd)
        print "Command: %s" %(cmd)
        print "Status: %s" %(status)
        print "Output:\n%s" %(output)
        self.assertEqual(status, 0, msg=("Command: %s failed" %cmd))

        # remove old datadir for restore
        print "Removing old datadir for restore..."
        cmd = "sudo salt %s cmd.run 'rm -rf /var/lib/mysql'" %(self.vm_name)
        status, output = commands.getstatusoutput(cmd)
        print "Command: %s" %(cmd)
        print "Status: %s" %(status)
        print "Output:\n%s" %(output)
        self.assertEqual(status, 0, msg=("Command: %s failed" %cmd))

        # run download + restore script
        cmd = 'sudo salt %s cmd.run cmd="python /root/download_and_restore.py --os_username=%s --os_password=%s --os_tenant_name=%s --os_auth_url=%s --swift_store_name=%s --encrypt_key=%s"' %( os.environ['TEST_MINION_NAME']
                                            , os.environ['OS_USER']
                                            , os.environ['OS_PASS']
                                            , os.environ['OS_TENANT_NAME']
                                            , os.environ['OS_AUTH_URL']
                                            , os.environ['SWIFT_STORE_NAME']
                                            , os.environ['ENCRYPT_KEY'])
        status, output = commands.getstatusoutput(cmd)
        print cmd
        print status
        print output
        self.assertEqual(status, 0, msg=("Command: %s failed" %cmd))

        # change the owner and group of datadir
        cmd = "sudo salt %s cmd.run 'chown -R mysql /var/lib/mysql '" %(self.vm_name)
        status, output = commands.getstatusoutput(cmd)
        print "Command: %s" %(cmd)
        print "Status: %s" %(status)
        print "Output:\n%s" %(output)
        self.assertEqual(status, 0, msg=("Command: %s failed" %cmd))

        cmd = "sudo salt %s cmd.run 'chgrp mysql /var/lib/mysql '" %(self.vm_name)
        status, output = commands.getstatusoutput(cmd)
        print "Command: %s" %(cmd)
        print "Status: %s" %(status)
        print "Output:\n%s" %(output)
        self.assertEqual(status, 0, msg=("Command: %s failed" %cmd))

        # restart mysql
        cmd = "sudo salt %s cmd.run 'service mysql start'" %(self.vm_name)
        status, output = commands.getstatusoutput(cmd)
        print "Command: %s" %(cmd)
        print "Status: %s" %(status)
        print "Output:\n%s" %(output)
        self.assertEqual(status, 0, msg=("Command: %s failed" %cmd))

        # run test queries
        queries = [ 'SHOW TABLES IN lbaas'
                  , 'SELECT * FROM lbaas.versions'
                  , 'SELECT COUNT(*) FROM lbaas.devices'
                  , 'SELECT COUNT(*) FROM lbaas.loadbalancers'
                  ]
        for query in queries:
            cmd = """sudo salt %s cmd.run "mysql -uroot -e '%s'" """ %(self.vm_name, query)
            status, output = commands.getstatusoutput(cmd)
            print "Command: %s" %(cmd)
            print "Status: %s" %(status)
            print "Output:\n%s" %(output)
            self.assertEqual(status, 0, msg=("Command: %s failed" %cmd))

    def tearDown(self):
        cmd = "sudo salt-cloud -y -d -C %s -p %s %s" %(self.config_file, self.profile_name, self.vm_name)
        status, output = commands.getstatusoutput(cmd)
        print "Command: %s" %(cmd)
        print "Status: %s" %(status)
        print "Output:\n%s" %(output)

