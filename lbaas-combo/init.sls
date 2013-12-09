include:
  - libra_common
  - lbaas-pyapi
  - lbaas-poolmgm
  - common_gearman
#  - lbaas-gearman
  - lbaas-galera

/etc/libra/libra_api.cfg:
  file:
    - managed
    - template: jinja
    - source: salt://lbaas-pyapi/libra.cfg
    - order: 999 

/etc/libra/libra_poolmgm.cfg:
  file:
    - managed
    - template: jinja
    - source: salt://lbaas-poolmgm/libra.cfg
    - order: 999

libra_combo_api_defaults:
  file:
    - managed
    - name: /etc/default/libra-api
    - source: salt://lbaas-combo/libra-api
    - order: 999 

libra_combo_admin_api_defaults:
  file:
    - managed
    - name: /etc/default/libra-admin-api
    - source: salt://lbaas-combo/libra-admin-api
    - order: 999

libra_combo_poolmgm_defaults:
  file:
    - managed
    - name: /etc/default/libra-pool-mgm
    - source: salt://lbaas-combo/libra-pool-mgm
    - order: 999

/etc/beaver.cfg:
  file:
    - managed
    - template: jinja
    - source: salt://lbaas-combo/beaver.cfg
    - order: 999 

stop_services:
  cmd.run:
    - name: service libra-api stop
    - name: service libra-admin-api stop
    - name: service libra-pool-mgm stop
    #- name: service gearman-job-server
    - order: last
