# Copyright 2012 Hewlett-Packard Development Company, L.P.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.

saltmaster_packages:
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

update_apt:
  cmd.run:
    - name: 'apt-get update'
    - order: 0

python_installs:
  cmd.run:
    - name: pip install requests eventlet python-novaclient python-swiftclient python-keystoneclient 
    - order: 2

/etc/salt/cloudconfigs:
  file.directory:
    - makedirs: True
    - user: root 
    - order: 4

/etc/salt/cloudconfigs/cloud_az3
  file:
    - managed
    - template: jinja
    - source: salt://lbaas-saltmaster/cloud_config_az3
    - order: 7

/root/.ssh/id_rsa:
  file:
    - managed
    - owner: root
    - mode: 600
    - source: salt://lbaas-saltmaster/id_rsa
    - order: 7

/root/.ssh/id_rsa.pub:
  file:
    - managed
    - owner: root
    - mode: 600
	- source: salt://lbaas-saltmaster/id_rsa.pub
    - order: 7

