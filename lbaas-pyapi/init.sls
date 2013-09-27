include:
  - libra_common

libra_api_packages:
  pkg.installed:
    - pkgs:
      - libra-api
      - libra-admin-api
    - order: 1

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

/etc/ssl/galera-ca-cert.pem:
  file:
    - managed
    - mode: 600
    - source: salt://debian-packages/galera-ca-cert.pem
    - owner: root
    - group: root
   
/etc/ssl/galera-client-cert.pem:
  file:
    - managed
    - mode: 600
    - source: salt://debian-packages/galera-client-cert.pem
    - owner: root
    - group: root

/etc/ssl/galera-client-key.pem:
  file:
    - managed
    - mode: 600
    - source: salt://debian-packages/galera-client-key.pem
    - owner: root
    - group: root
 
