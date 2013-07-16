libra_worker_packages:
  pkg.installed:
    - pkgs:
      - git
      - debconf-utils
      - socat
      - build-essential
      - haproxy
      - python-setuptools
      - python-dev
      - python-pip
      - python-mysqldb
    - order: 1

update_apt:
  cmd.run:
    - name: 'apt-get update'
    - order: 0

get_pip:
  cmd.run:
    - name: curl -O https://raw.github.com/pypa/pip/master/contrib/get-pip.py
    - order: 0

install_pip:
  cmd.run:
    - name: python get-pip.py
    - order: 1


/etc/sudoers:
  file:
    - managed
    - source: salt://lbaas-haproxy-base/sudoers
    - user: root
    - mode: 400
    - order: 2

/var/log/libra:
    file.directory:
    - user: haproxy
    - group: haproxy 
    - mode: 755
    - makedirs: True
    - order: 4

create_libra_log:
  cmd.run:
    - user: haproxy
    - name: touch /var/log/libra/libra_worker.log
    - require:
      - file: /var/log/libra
    - order: 5

/var/run/libra:
  file.directory:
  - user: haproxy
  - group: haproxy 
  - mode: 755
  - makedirs: True
  - order: 5

/mnt/log:
  file.directory:
  - user: haproxy
  - group: haproxy
  - mode: 755
  - makedirs: True
  - order: 5

/etc/rsyslog.d/10-haproxy.conf:
  file:
    - managed
    - source: salt://lbaas-haproxy-base/10-haproxy.conf
    - order: 6

/etc/logrotate.d/haproxy:
  file:
    - managed
    - source: salt://lbaas-haproxy-base/haproxy_logrotate.conf
    - order: 6

/etc/default/haproxy:
  file:
    - managed
    - source: salt://lbaas-haproxy-base/haproxy
    - order: 6

/etc/libra.cfg:
  file:
    - managed
    - template: jinja
    - source: salt://lbaas-haproxy-base/libra.cfg
    - order: 7

/etc/init/libra_worker.conf:
  file:
    - managed
    - source: salt://lbaas-haproxy-base/libra_worker.conf
    - order: 8 

python-gearman-git:
   require:
     - pkg: git
   git.latest:
    - cwd: /home/ubuntu
    - name: https://github.com/Yelp/python-gearman.git
    - rev: worker-coaxing
    - target: /home/ubuntu/python-gearman
    - force: True
    - order: 48

libra-git:
   require:
     - pkg: git
   git.latest:
    - cwd: /home/ubuntu
    - name: https://github.com/stackforge/libra.git
    - target: /home/ubuntu/libra
    - force: True
    - order: 49

setup-libra-worker:
  require:
    - pkg: git
    - pkg: python-setuptools
  cmd.run:
    - name: 'sudo python setup.py install'
    - cwd: /home/ubuntu/libra
    - order: 50 

setup-python-gearman:
  require:
    - pkg: git
    - pkg: python-setuptools
  cmd.run:
    - name: 'sudo python setup.py install'
    - cwd: /home/ubuntu/python-gearman
    - order: 51

/etc/beaver.cfg:
  file:
    - managed
    - template: jinja
    - source: salt://lbaas-haproxy-base/beaver.cfg

install_pbr:
  cmd.run:
    - name: 'pip install pbr'
    - order: last
