include:
  - libra_common

libra_api_packages:
  pkg.installed:
    - pkgs:
      - libra-api
      - libra-admin-api
    - order: 1

dogapi_install:
  cmd.run: 
    - name: pip install -U dogapi
    - order: 0

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

/etc/libra.cfg:
  file:
    - managed
    - template: jinja
    - source: salt://lbaas-pyapi/libra.cfg
    - order: 0 

{{ pillar['lbaas_api_keystone_ca_certs_path'] }}:
  file:
    - managed
    - template: jinja
    - source: salt://lbaas-pyapi/ca.pem
    - owner: libra
    - group: libra

{{ pillar['lbaas_api_keystone_certfile_path'] }}:
  file:
    - managed
    - template: jinja
    - source: salt://lbaas-pyapi/hpmiddleware.pem
    - owner: libra
    - group: libra

{{ pillar['lbaas_api_ssl_certfile_path'] }}:
  file:
    - managed
    - template: jinja
    - source: salt://lbaas-pyapi/server.crt
    - owner: libra
    - group: libra

{{ pillar['lbaas_api_ssl_keyfile_path'] }}:
  file:
    - managed
    - template: jinja
    - source: salt://lbaas-pyapi/server.key
    - owner: libra
    - group: libra

/etc/beaver.cfg:
  file:
    - managed
    - template: jinja
    - source: salt://lbaas-pyapi/beaver.cfg

/etc/ssl/galera-ca-cert.pem:
  file:
    - managed
    - mode: 600
    - source: salt://debian-packages/galera-ca-cert.pem
    - owner: libra 
    - group: libra 
   
/etc/ssl/galera-client-cert.pem:
  file:
    - managed
    - mode: 600
    - source: salt://debian-packages/galera-client-cert.pem
    - owner: libra 
    - group: libra 

/etc/ssl/galera-client-key.pem:
  file:
    - managed
    - mode: 600
    - source: salt://debian-packages/galera-client-key.pem
    - owner: libra 
    - group: libra 

/var/log/libra:
  file.directory:
    - user: libra
    - group: libra
    - mode: 755
    - makedirs: True

{% if pillar['use_datadog'] == True %}
install_datadog:
  cmd.run:
    - name: 'DD_API_KEY={{ pillar['lbaas_datadog_api_key'] }} bash -c "$(wget -qO- http://dtdg.co/agent-install-ubuntu)"'
    - order: 2

/etc/dd-agent/datadog.conf:
  file:
    - managed
    - template: jinja
    - source: salt://lbaas-pyapi/datadog.conf
    - order: 7

/opt/api_log.py:
  file:
    - managed
    - source: salt://lbaas-pyapi/api_log.py
    - order: 7

/opt/adminapilogs.py:
  file:
    - managed
    - source: salt://lbaas-pyapi/adminapilogs.py
    - order: 7

/usr/share/datadog/agent/checks.d/network.py:
  file:
    - managed
    - source: salt://lbaas-pyapi/network.py
    - order: 7

/usr/share/datadog/agent/checks.d/testapi.py:
  file:
    - managed
    - source: salt://lbaas-pyapi/testapi.py
    - order: 7

/etc/dd-agent/conf.d/network.yaml:
  file:
    - managed
    - source: salt://lbaas-pyapi/network.yaml
    - order: 7

/etc/dd-agent/conf.d/testapi.yaml:
  file:
    - managed
    - template: jinja
    - source: salt://lbaas-pyapi/testapi.yaml
    - order: 7
{% endif %} 
