libra_statsd_packages:
  pkg.installed:
    - pkgs:
      - git
      - debconf-utils
      - build-essential
      - python-setuptools
      - python-dev
#      - python-pip
      - python-mysqldb
    - order: 1

get_pip:
  cmd.run:
    - name: curl -O https://raw.github.com/pypa/pip/master/contrib/get-pip.py
    - order: 0

install_pip:
  cmd.run:
    - name: python get-pip.py
    - order: 1
    
update_apt:
  cmd.run:
    - name: 'apt-get update'
    - order: 0

python_installs:
  cmd.run:
    - name: pip install requests dogapi python-daemon eventlet python-novaclient python-swiftclient pbr gearman
    - order: 2

add_libra_group:
    cmd.run:
      - name: 'groupadd libra'
      - order: 2

libra:
    user.present:
      - fullname: libra
      - groups:
        - libra
      - order: 3

/var/run/libra:
  file.directory:
    - makedirs: True
    - user: libra 
    - mode: 755
    - order: 4

/var/log/libra:
  file.directory:
    - makedirs: True
    - user: libra 
    - mode: 755
    - order: 4

/etc/libra.cfg:
  file:
    - managed
    - template: jinja
    - source: salt://lbaas-statsd/libra.cfg
    - order: 7

libra-git:
   require:
     - pkg: git
   git.latest:
    - cwd: /home/ubuntu
    - name: https://github.com/stackforge/libra.git
    - target: /home/ubuntu/libra
    - force: True

setup-statsd:
  require:
    - pkg: git
    - pkg: python-setuptools
  cmd.run:
    - name: 'sudo python setup.py install'
    - cwd: /home/ubuntu/libra
    - order: last 

/etc/beaver.cfg:
  file:
    - managed
    - template: jinja
    - source: salt://lbaas-statsd/beaver.cfg
