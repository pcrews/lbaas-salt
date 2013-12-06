include:
  - libra_common
  - lbaas_pyapi
  - lbaas_poolmgm
  - lbaas_gearman
  - lbaas_galera

/etc/libra_api.cfg:
  file:
    - managed
    - template: jinja
    - source: salt://lbaas-pyapi/libra.cfg
    - order: 999 

/etc/libra_poolmgm.cfg:
  file:
    - managed
    - template: jinja
    - source: salt://lbaas-poolmgm/libra.cfg
    - order: 999

/etc/beaver.cfg:
  file:
    - managed
    - template: jinja
    - source: salt://lbaas-combo/beaver.cfg
    - order: 999 
