/etc/ssl/gearmand-ca.pem:
  file:
    - managed
    - template: jinja
    - source: salt://lbaas-gearman/gearmand-ca.pem
    - order: 6

/etc/ssl/gearman.key:
  file:
    - managed
    - template: jinja
    - source: salt://lbaas-gearman/gearman.key
    - order: 6

/etc/ssl/gearman.pem:
  file:
    - managed
    - template: jinja
    - source: salt://lbaas-gearman/gearman.pem
    - order: 6

