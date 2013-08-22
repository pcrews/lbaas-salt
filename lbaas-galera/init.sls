required_packages:
  pkg.installed:
    - pkgs:
      - git
      - python-mysqldb 
      - python-pip
    - order: 1

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

install-cluster:
  cmd.run:
    - name: apt-get install -y percona-xtradb-cluster-server-5.5 percona-xtradb-cluster-client-5.5 percona-xtrabackup 
    - order: 5

/root/backup_and_store_directory.py:
  file:
    - managed
    - source: salt://scripts/backup_and_store_directory.py

/etc/mysql/my.cnf:
  file:
    - managed
    - template: jinja
    - source: salt://lbaas-galera/my.cnf
    - order: 8

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
  - order: 200

{{ pillar['lbaas_api_mysql_user'] }}:
  mysql_user.present:
    - host: {{ pillar['lbaas_api_1'] }} 
    - password: '{{ pillar['lbaas_api_mysql_pw'] }}' 
    - order: 900

{{ pillar['lbaas_galera_rpl_user'] }}:
  mysql_user.present:
    - host: localhost
    - password: {{ pillar['lbaas_galera_rpl_pw'] }}
    - order: 1000 

galera_user_grants:
  mysql_grants.present:
    - grant: RELOAD, LOCK TABLES, REPLICATION CLIENT
    - database: '*.*'
    - user: {{ pillar['lbaas_galera_rpl_user'] }}
    - host: localhost
    - order: 1001

{% if pillar['use_beaver'] == 'True' %}
/etc/beaver.cfg:
  file:
    - managed
    - template: jinja
    - source: salt://lbaas-galera/beaver.cfg
{% endif %}

{% if pillar['galera_ssh'] == 'True' %}
/etc/mysql/galera-key.pem:
  file:
    - managed
    - mode: 600
    - owner: mysql
    - group: mysql
    - source: salt://debian-packages/galera-key.pem

/etc/mysql/galera-cert.pem:
  file:
    - managed
    - mode: 600
    - owner: mysql
    - group: mysql
    - source: salt://debian-packages/galera-cert.pem

/etc/mysql/galera-ca-cert.pem:
  file:
    - managed
    - mode: 600
    - owner: mysql
    - group: mysql
    - source: salt://debian-packages/galera-ca-cert.pem

/etc/mysql/galera-server-cert.pem:
  file:
    - managed
    - mode: 600
    - owner: mysql
    - group: mysql
    - source: salt://debian-packages/galera-server-cert.pem

/etc/mysql/galera-server-key.pem:
  file:
    - managed
    - mode: 600
    - owner: mysql
    - group: mysql
    - source: salt://debian-packages/galera-server-key.pem

{% endif %}

