libra_worker_packages:
  pkg.installed:
    - pkgs:
      - git
      - debconf-utils
      - build-essential
      - python-setuptools
      - python-dev
      - default-jre
      - python-pip
    - order: 1

pip_packages:
  cmd.run:
    - name: pip install python-swiftclient python-novaclient python-keystoneclient
    - order: 2

logstash:
  user.present:
    - home: /home/logstash
    - shell: /bin/nologin
    - system: True
    - gid_from_name: True
    - require:
      - group: logstash
  group.present:
    - system: True
  file.managed:
    - source: https://logstash.objects.dreamhost.com/release/logstash-1.1.12-flatjar.jar
    - source_hash: md5=0177b73539a22b42f95611393cb566b1
    - name: /home/logstash/logstash.jar
    - user: logstash
    - group: logstash
    - require:
      - user: logstash
      - group: logstash

/var/log/logstash:
  file.directory:
    - user: logstash
    - group: logstash
    - require:
      - user: logstash
      - group: logstash

/etc/logstash:
  file.directory:
    - user: logstash
    - group: logstash
    - require:
      - user: logstash
      - group: logstash

/etc/logstash/agent.conf:
  file:
    - managed
    - template: jinja
    - source: salt://logstash/agent.conf.beaver

/etc/init/logstash-agent.conf:
  file:
    - managed
    - template: jinja
    - source: salt://logstash/logstash-agent.conf

/etc/init/sshtunnel.conf:
  file:
    - managed
    - template: jinja
    - source: salt://logstash/sshtunnel.conf

/etc/ssl/logstash.pub:
  file:
    - managed
    - template: jinja
    - source: salt://logstash/logstash.pub

/etc/ssl/logstash.key:
  file:
    - managed
    - template: jinja
    - source: salt://logstash/logstash.key

/etc/ssl/paas_logstash.pub:
  file:
    - managed
    - template: jinja
    - source: salt://logstash/paas_logstash.pub

/etc/ssl/paas_logstash.key:
  file:
    - managed
    - template: jinja
    - source: salt://logstash/paas_logstash.key

start_logstash:
  cmd.run:
    - name: /usr/bin/java -jar /home/logstash/logstash.jar agent -f /etc/logstash/agent.conf --log /var/log/logstash/agent.log &
    #- name: echo "I wish I could start logstash... :("
    - order: last
    - require:
      - file: /etc/ssl/logstash.key
      - file: /etc/ssl/logstash.pub

