/etc/ssl/gearmand-ca.pem:
  file:
    - managed
    - template: jinja
    - mode: 644 
    - source: salt://debian-packages/gearmand-ca.pem
    - order: 6

/etc/ssl/gearman.key:
  file:
    - managed
    - template: jinja
    - mode: 644
    - source: salt://debian-packages/gearman.key
    - order: 6

/etc/ssl/gearman.pem:
  file:
    - managed
    - template: jinja
    - mode: 600
    - source: salt://debian-packages/gearman.pem
    - order: 6


