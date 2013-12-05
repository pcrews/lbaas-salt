/etc/ssl/gearmand-ca.pem:
  file:
    - managed
    - template: jinja
    - mode: 644 
    {% if 'pyapi' in grains['fqdn'] %}
    - owner: libra
    - group: libra 
    {% elif 'haproxy' in grains['fqdn'] %}
    - owner: libra 
    - group: libra 
    {% elif 'pool' in grains['fqdn'] %}
    - owner: libra
    - group: libra
    {% endif %}
    - source: salt://debian-packages/gearmand-ca.pem
    - order: 6

/etc/ssl/gearman.key:
  file:
    - managed
    - template: jinja
    - mode: 600
    {% if 'pyapi' in grains['fqdn'] %}
    - owner: libra 
    - group: libra 
    {% elif 'haproxy' in grains['fqdn'] %}
    - owner: libra 
    - group: libra 
    {% elif 'pool' in grains['fqdn'] %}
    - owner: libra
    - group: libra
    {% endif %}
    - source: salt://debian-packages/gearman.key
    - order: 6

/etc/ssl/gearman.pem:
  file:
    - managed
    - template: jinja
    - mode: 644
    {% if 'pyapi' in grains['fqdn'] %}
    - owner: libra 
    - group: libra 
    {% elif 'haproxy' in grains['fqdn'] %}
    - owner: libra 
    - group: libra
    {% elif 'pool' in grains['fqdn'] %}
    - owner: libra
    - group: libra
    {% endif %}
    - source: salt://debian-packages/gearman.pem
    - order: 6


