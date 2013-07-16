# Copyright 2012 Hewlett-Packard Development Company, L.P.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.

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
