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
{% if pillar['gearman_ssl'] == 'True' %}
ssl_pkg_cyassl:
   file.managed:
     - name: /home/ubuntu/cyassl_2.7.0-1_amd64.deb
     - source: salt://debian-packages/cyassl_2.7.0-1_amd64.deb
   cmd.run:
     - name: dpkg -i cyassl_2.7.0-1_amd64.deb
     - cwd: /home/ubuntu
     - require:
       - file: /home/ubuntu/cyassl_2.7.0-1_amd64.deb
     - order: 1

ssl_pkg_libgearman:
   file.managed:
     - name: /home/ubuntu/libgearman8_1.1.9~20130802-1_amd64.deb
     - source: salt://debian-packages/libgearman8_1.2~20130725-1_amd64.deb
   cmd.run:
     - name: dpkg -i libgearman8_1.1.1.9~20130802-1_amd64.deb
     - cwd: /home/ubuntu
     - require:
       - file: /home/ubuntu/libgearman8_1.1.9~20130802-1_amd64.deb
     - order: 2

ssl_pkg_gearman_job_server:
   file.managed:
     - name: /home/ubuntu/gearman-job-server_1.1.9~20130802-1_amd64.deb
     - source: salt://debian-packages/gearman-job-server_1.1.9~20130802-1_amd64.deb
   cmd.run:
     - name: dpkg -i gearman-job-server_1.1.9~20130802-1_amd64.deb
     - cwd: /home/ubuntu
     - require:
       - file: /home/ubuntu/gearman-job-server_1.1.9~20130802-1_amd64.deb
     - order: 3

ssl_gearman_tools:
   file.managed:
     - name: /home/ubuntu/gearman-tools_1.1.9~20130802-1_amd64.deb
     - source: salt://debian-packages/gearman-tools_1.1.9~20130802-1_amd64.deb
   cmd.run:
     - name: dpkg -i gearman-tools_1.1.9~20130802-1_amd64.deb
     - cwd: /home/ubuntu
     - require:
       - file: /home/ubuntu/gearman-tools_1.1.9~20130802-1_amd64.deb
     - order: 4

/etc/ssl/certs/gearmand-ca.pem:
  file:
    - managed
    - template: jinja
    - mode: 644
    - owner: gearman
    - group: gearman
    - source: salt://debian-packages/gearmand-ca.pem
    - order: 6

/etc/ssl/certs/gearmand.key:
  file:
    - managed
    - template: jinja
    - mode: 600
    - owner: gearman
    - group: gearman
    - source: salt://debian-packages/gearmand.key
    - order: 6

/etc/ssl/certs/gearmand.pem:
  file:
    - managed
    - template: jinja
    - mode: 644
    - owner: gearman
    - group: gearman
    - source: salt://debian-packages/gearmand.pem
    - order: 6

/etc/ssl/certs/gearman.key:
  file:
    - managed
    - template: jinja
    - mode: 600
    - owner: ubuntu
    - group: ubuntu
    - source: salt://debian-packages/gearman.key
    - order: 6

/etc/ssl/certs/gearman.pem:
  file:
    - managed
    - template: jinja
    - mode: 644
    - owner: ubuntu
    - group: ubuntu
    - source: salt://debian-packages/gearman.pem
    - order: 6
{% else %}

required_packages:
  pkg.installed:
    - pkgs:
      - gearman-job-server
      - gearman-tools
    - order: 1

{% endif %}

update_apt:
  cmd.run:
    - name: apt-get update
    - order: 5

fix_packaging:
  cmd.run:
    - name: apt-get -f -y install
    - order: 6 

/etc/default/gearman-job-server:
  file:
    - managed
    - source: salt://lbaas-gearman/gearman-job-server
    - order: 6 

stop_gearman:
  cmd.run:
    - name: 'service gearman-job-server stop'
    - order: 7 

start_gearman:
  cmd.run:
    - name: 'service gearman-job-server start '
    - order: last 

{% if pillar['use_beaver'] == 'True' %}
/etc/beaver.cfg:
  file:
    - managed
    - template: jinja
    - source: salt://lbaas-gearman/beaver.cfg
    - order: 6
{% endif %}


