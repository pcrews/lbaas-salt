from fabric.api import run, env, put, sudo, settings, cd
from fabric.contrib.files import append
import time

env.user = 'ubuntu'

def find_libra():
    run('sudo  ps -aux | grep libra')

def find_haproxy():
    run('sudo ps -aux | grep haproxy')

def find_libra_cnf():
    run('sudo ls /etc/libra.cnf')

def stop_libra_worker():
    run('sudo killall libra_worker')

def start_libra_worker():
    run('sudo libra_worker -c /etc/libra.cfg')

def restart_libra_worker():
    stop_libra_worker()
    time.sleep(2)
    start_libra_worker() 
    find_libra()

def taskB():
    run('whoami')

def put_file(file, dest):
    put(file, dest, use_sudo=True) # it's copied into the target directory

def remove_file(file):
    run('rm %s' %file)

def get_libra_version():
  #run('libra_worker --version')
  sudo('libra_worker --version', user='root')

def start_beaver():
  with settings(warn_only=True):
    run('sudo service beaver start')

def restart_beaver():
  run('sudo service beaver restart')

def test_beaver():
  run('sudo tail /var/log/beaver.log')
