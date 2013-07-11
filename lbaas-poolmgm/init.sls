libra_worker_packages:
  pkg.installed:
    - pkgs:
      - git
      - debconf-utils
      - build-essential
      - python-setuptools
      - python-dev
      - python-pip
      - python-mysqldb
    - order: 1

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
    - source: salt://lbaas-poolmgm/libra.cfg
    - order: 7

libra-git:
   require:
     - pkg: git
   git.latest:
    - cwd: /home/ubuntu
    - name: https://github.com/stackforge/libra.git
    - rev: release-v3
    - target: /home/ubuntu/libra
    - force: True
    - order: 99

setup-libra-pool-mgm:
  require:
    - pkg: git
    - pkg: python-setuptools
  cmd.run:
    - name: 'sudo python setup.py install'
    - cwd: /home/ubuntu/libra
    - order:  last 

/etc/beaver.cfg:
  file:
    - managed
    - template: jinja
    - source: salt://lbaas-poolmgm/beaver.cfg
    
