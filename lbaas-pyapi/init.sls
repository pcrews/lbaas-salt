libra_api_packages:
  pkg.installed:
    - pkgs:
      - git
      - debconf-utils
      - build-essential
      - python-setuptools
      - python-dev
      - python-pip
      - python-mysqldb
      - python-pastedeploy
      - python-six
      - python-webob
      - python-eventlet
      - python-lxml
      - python-routes
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

{% macro install_deb(deb_name) -%}
lbaasapi-install-deb-{{ deb_name }}:
   file.managed:
     - name: /home/ubuntu/{{ deb_name }}
     - source: salt://debian-packages/{{ deb_name}}
   cmd.run:
     - name: dpkg -i {{ deb_name }}
     - cwd: /home/ubuntu
     - require: 
       - file: /home/ubuntu/{{ deb_name }}
{%- endmacro %}

{{ install_deb('python-keystone_2.0.4_all.deb') }}
{{ install_deb('keystone_2.0.4_all.deb') }}
{{ install_deb('hp-cs-thrift_2.0_amd64.deb') }}
{{ install_deb('hp-cs-middleware_1.0.15.33_amd64.deb') }}

/root/backup_and_store_directory.py:
  file:
    - managed
    - source: salt://scripts/backup_and_store_directory.py

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

/var/log/libra:
    file.directory:
    - user: libra 
    - group: libra 
    - mode: 755
    - makedirs: True
    - order: 4

create_libra_log:
  cmd.run:
    - user: libra 
    - name: touch /var/log/libra/api.log
    - require:
      - file: /var/log/libra
    - order: 5

create_admin_api_log:
  cmd.run:
    - user: libra 
    - name: touch /var/log/libra/admin_api.log
    - require:
      - file: /var/log/libra
    - order: 5

/var/run/libra:
  file.directory:
  - user: libra 
  - group: libra 
  - mode: 755
  - makedirs: True
  - order: 5

/etc/libra.cfg:
  file:
    - managed
    - template: jinja
    - source: salt://lbaas-pyapi/libra.cfg
    - order: 7

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

setup-libra:
  require:
    - pkg: git
    - pkg: python-setuptools
  cmd.run:
    - name: 'sudo python setup.py install'
    - cwd: /home/ubuntu/libra
    - order: last 

setup-python-gearman:
  require:
    - pkg: git
    - pkg: python-setuptools
  cmd.run:
    - name: 'sudo python setup.py install'
    - cwd: /home/ubuntu/python-gearman
    - order: last 

{{ pillar['lbaas_api_keystone_ca_certs_path'] }}:
  file:
    - managed
    - template: jinja
    - source: salt://lbaas-pyapi/ca.pem

{{ pillar['lbaas_api_keystone_certfile_path'] }}:
  file:
    - managed
    - template: jinja
    - source: salt://lbaas-pyapi/hpmiddleware.pem

{{ pillar['lbaas_api_ssl_certfile_path'] }}:
  file:
    - managed
    - template: jinja
    - source: salt://lbaas-pyapi/server.crt

{{ pillar['lbaas_api_ssl_keyfile_path'] }}:
  file:
    - managed
    - template: jinja
    - source: salt://lbaas-pyapi/server.key

/etc/beaver.cfg:
  file:
    - managed
    - template: jinja
    - source: salt://lbaas-pyapi/beaver.cfg

