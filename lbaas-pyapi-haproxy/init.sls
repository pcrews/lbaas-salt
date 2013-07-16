libra_worker_packages:
  pkg.installed:
    - pkgs:
      - git
      - debconf-utils
      - socat
      - build-essential
      - haproxy
      - python-setuptools
      - python-dev
      - python-pip
    - order: 1

update_apt:
  cmd.run:
    - name: 'apt-get update'
    - order: 0

/etc/rsyslog.d/10-haproxy.conf:
  file:
    - managed
    - source: salt://lbaas-pyapi-haproxy/10-haproxy.conf
    - order: 6

/etc/logrotate.d/haproxy:
  file:
    - managed
    - source: salt://lbaas-pyapi-haproxy/haproxy_logrotate.conf
    - order: 6

/etc/default/haproxy:
  file:
    - managed
    - source: salt://lbaas-pyapi-haproxy/haproxy
    - order: 6

/etc/haproxy.cfg:
  file:
    - managed
    - template: jinja
    - source: salt://lbaas-pyapi-haproxy/haproxy.cfg
