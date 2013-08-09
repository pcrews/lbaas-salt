/etc/ssl/gearmand-ca.pem:
  file:
    - managed
    - template: jinja
    - mode: 644 
    {% if 'pyapi' in grains['fqdn'] %}
    - owner: root 
    - group: root 
    {% elif 'haproxy' in grains['fqdn'] %}
    - owner: haproxy
    - group: haproxy
    {% endif %}
    - source: salt://debian-packages/gearmand-ca.pem
    - order: 6

/etc/ssl/gearman.key:
  file:
    - managed
    - template: jinja
    - mode: 600
    {% if 'pyapi' in grains['fqdn'] %}
    - owner: root 
    - group: root 
    {% elif 'haproxy' in grains['fqdn'] %}
    - owner: haproxy
    - group: haproxy
    {% endif %}
    - source: salt://debian-packages/gearman.key
    - order: 6

/etc/ssl/gearman.pem:
  file:
    - managed
    - template: jinja
    - mode: 644
    {% if 'pyapi' in grains['fqdn'] %}
    - owner: root
    - group: root 
    {% elif 'haproxy' in grains['fqdn'] %}
    - owner: haproxy
    - group: haproxy
    {% endif %}
    - source: salt://debian-packages/gearman.pem
    - order: 6


