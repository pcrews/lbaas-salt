beaver_logging_packages:
  pkg.installed:
    - pkgs:
      - git
      - debconf-utils
      - build-essential
      - python-setuptools
      - python-dev
      - python-pip
    - order: 1

beaver-git:
   require:
     - pkg: git
   git.latest:
    - cwd: /home/ubuntu
    - name: https://github.com/josegonzalez/beaver.git 
    - target: /home/ubuntu/beaver
    - force: True

/etc/ssl/beaver_rsa:
  file:
    - managed
    - template: jinja
    - mode: 600
    - source: salt://common_logging/beaver_rsa

/etc/init/beaver.conf:
  file:
    - managed
    - mode: 644
    - source: salt://common_logging/beaver.conf

{{ pillar['logging_ssh_remote_host'] }}:
  ssh_known_hosts:
    - present
    - user: root
    - fingerprint: {{ pillar['logging_ssh_remote_host_fingerprint'] }} 

install_beaver:
  cmd.run:
    - name: 'python setup.py install'
    - cwd: /home/ubuntu/beaver
    - order: last
