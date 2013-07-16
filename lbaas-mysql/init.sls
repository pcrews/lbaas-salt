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

update_apt0: 
  cmd.run:
     - name: apt-get update
     - order: 0 

required_packages:
  pkg.installed:
    - pkgs:
      - git
      - python-mysqldb
      - mysql-server    
    - order: 1

mysql:
  service:
    - running
    - order: 2 

percona-apt-repo:
  cmd.run:
    - name: gpg --keyserver  hkp://keys.gnupg.net --recv-keys 1C4CBDCDCD2EFD2A
    - order: 2

percona-apt-repo2:
  cmd.run:
    - name: gpg -a --export CD2EFD2A | sudo apt-key add -
    - order: 3 
    
percona-apt-sources:
  file.append:
    - name: /etc/apt/sources.list
    - text: |

          deb http://repo.percona.com/apt precise main
          deb-src http://repo.percona.com/apt precise main
    - order: 3

update-apt:
  cmd.run:
     - name: apt-get update
     - order: 4

install-xtrabackup:
  cmd.run:
    - name: apt-get install -y percona-xtrabackup
    - order: 5

/mnt/mysql_backups:
  file.directory:
  - user: root 
  - mode: 755
  - makedirs: True
  - order: 5

/etc/mysql/my.cnf:
  file:
    - managed
    - source: salt://lbaas-mysql/my.cnf
    - watch_in:
       - service: mysql 
    - order: 8

/root/backup_and_store_directory.py:
  file:
    - managed
    - source: salt://scripts/backup_and_store_directory.py

mysql-minion:
  file.append:
  - name: /etc/salt/minion
  - text: |
       # MySQL-module-specific data
       mysql.host: 'localhost'
       mysql.port: {{ pillar['lbaas_mysql_port'] }} 
       mysql.user: {{ pillar['lbaas_local_mysql_user'] }} 
       mysql.pass: {{ pillar['lbaas_local_mysql_pw'] }} 
       mysql.db: 'mysql'

mysql-lbaas user
{{ pillar['lbaas_api_mysql_user'] }}:
  mysql_user.present:
    - host: {{ pillar['lbaas_api_1'] }} 
    - password: '{{ pillar['lbaas_api_mysql_pw'] }}' 
    - require:
      - cmd: install-lbaas-db 

