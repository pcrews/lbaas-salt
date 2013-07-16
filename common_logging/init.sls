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

beaver_logging_packages:
  pkg.installed:
    - pkgs:
      - git
      - debconf-utils
      - build-essential
      - python-setuptools
      - python-dev
      - python-pip
    - order: 1

beaver-git:
   require:
     - pkg: git
   git.latest:
    - cwd: /home/ubuntu
    - name: https://github.com/josegonzalez/beaver.git 
    - target: /home/ubuntu/beaver
    - force: True

/etc/ssl/beaver_rsa:
  file:
    - managed
    - template: jinja
    - mode: 600
    - source: salt://common_logging/beaver_rsa

/etc/init/beaver.conf:
  file:
    - managed
    - mode: 644
    - source: salt://common_logging/beaver.conf

{{ pillar['logging_ssh_remote_host'] }}:
  ssh_known_hosts:
    - present
    - user: root
    - fingerprint: {{ pillar['logging_ssh_remote_host_fingerprint'] }} 

install_beaver:
  cmd.run:
    - name: 'python setup.py install'
    - cwd: /home/ubuntu/beaver
    - order: last
