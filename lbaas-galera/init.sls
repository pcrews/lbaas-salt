required_packages:
  pkg.installed:
    - pkgs:
      - git
      - python-mysqldb 
      - python-pip
    - order: 1

pip_installs:
  cmd.run:
    - name: pip install requests python-swiftclient python-keystoneclient
    - order: 2

/mnt/mysql_backups:
  file.directory:
    - user: root
    - group: root

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

libra_galera_backup_script:
  file:
    - managed
    - name: /root/backup_and_store_directory.py
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

lbaas_api1_user:
  mysql_user.present:
    - name: {{ pillar['lbaas_api_mysql_user'] }}
    - host: {{ pillar['lbaas_api_1'] }} 
    - password: '{{ pillar['lbaas_api_mysql_pw'] }}' 
    - order: 900

lbaas_api2_user:
  mysql_user.present:
    - name: {{ pillar['lbaas_api_mysql_user'] }}
    - host: {{ pillar['lbaas_api_2'] }}
    - password: '{{ pillar['lbaas_api_mysql_pw'] }}'
    - order: 900

lbaas_api3_user:
  mysql_user.present:
    - name: {{ pillar['lbaas_api_mysql_user'] }}
    - host: {{ pillar['lbaas_api_3'] }}
    - password: '{{ pillar['lbaas_api_mysql_pw'] }}'
    - order: 900

lbaas_api1_user_floater:
  mysql_user.present:
    - name: {{ pillar['lbaas_api_mysql_user'] }}
    - host: {{ pillar['lbaas_api_1_floating_ip'] }}
    - password: '{{ pillar['lbaas_api_mysql_pw'] }}'
    - order: 900

lbaas_api2_user_floater:
  mysql_user.present:
    - name: {{ pillar['lbaas_api_mysql_user'] }}
    - host: {{ pillar['lbaas_api_2_floating_ip'] }}
    - password: '{{ pillar['lbaas_api_mysql_pw'] }}'
    - order: 900

lbaas_api3_user_floater:
  mysql_user.present:
    - name: {{ pillar['lbaas_api_mysql_user'] }}
    - host: {{ pillar['lbaas_api_3_floating_ip'] }}
    - password: '{{ pillar['lbaas_api_mysql_pw'] }}'
    - order: 900

api1_user_grants:
  mysql_grants.present:
    - grant: ALL 
    - database: 'lbaas.*'
    - user: {{ pillar['lbaas_api_mysql_user'] }}
    - host: {{ pillar['lbaas_api_1'] }} 
    - order: 901

api2_user_grants:
  mysql_grants.present:
    - grant: ALL
    - database: 'lbaas.*'
    - user: {{ pillar['lbaas_api_mysql_user'] }}
    - host: {{ pillar['lbaas_api_2'] }}
    - order: 901

api3_user_grants:
  mysql_grants.present:
    - grant: ALL
    - database: 'lbaas.*'
    - user: {{ pillar['lbaas_api_mysql_user'] }}
    - host: {{ pillar['lbaas_api_3'] }}
    - order: 901

api1_user_grants_floater:
  mysql_grants.present:
    - grant: ALL
    - database: 'lbaas.*'
    - user: {{ pillar['lbaas_api_mysql_user'] }}
    - host: {{ pillar['lbaas_api_1_floating_ip'] }}
    - order: 901

api2_user_grants_floater:
  mysql_grants.present:
    - grant: ALL
    - database: 'lbaas.*'
    - user: {{ pillar['lbaas_api_mysql_user'] }}
    - host: {{ pillar['lbaas_api_2_floating_ip'] }}
    - order: 901

api3_user_grants_floater:
  mysql_grants.present:
    - grant: ALL
    - database: 'lbaas.*'
    - user: {{ pillar['lbaas_api_mysql_user'] }}
    - host: {{ pillar['lbaas_api_3_floating_ip'] }}
    - order: 901

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

{% if pillar['use_datadog'] == True %}
install_datadog:
  cmd.run:
    - name: DD_API_KEY={{ pillar['lbaas_datadog_api_key'] }}  bash -c "$(wget -qO- http://dtdg.co/agent-install-ubuntu)"
    - order: 2

{{ pillar['lbaas_datadog_mysql_user'] }}:
  mysql_user.present:
    - host: localhost
    - password: {{ pillar['lbaas_datadog_mysql_pw'] }}
    - order: 1000

/etc/dd-agent/datadog.conf:
  file:
    - managed
    - template: jinja
    - source: salt://lbaas-galera/datadog.conf
    - order: 7
    
/usr/share/datadog/agent/checks.d/network.py:
  file:
    - managed
    - source: salt://lbaas-galera/network.py
    - order: 7
{% endif %}

{% if pillar['use_beaver'] == True %}
libra_galera_beaver_config:
  file:
    - managed
    - name: /etc/beaver.cfg
    - template: jinja
    - source: salt://lbaas-galera/beaver.cfg
{% endif %}

{% if pillar['galera_ssl'] == True %}
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

