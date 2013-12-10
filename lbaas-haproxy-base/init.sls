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
include:
  - libra_common

libra_worker_packages:
  pkg.installed:
    - pkgs:
      - libra-worker
    - order: 1

/etc/libra/libra.cfg:
  file:
    - managed
    - template: jinja
    - source: salt://lbaas-haproxy-base/libra.cfg
    - order: 0

stop_libra_worker:
  cmd.run:
    - name: service libra-worker stop
    - order: 2

/etc/libra/logging_worker.cfg:
  file:
    - managed
    - source: salt://lbaas-haproxy-base/logging_worker.cfg
    - owner: libra
    - group: libra
    - order: 2 

/etc/default/libra-worker:
  file:
    - managed
    - source: salt://lbaas-haproxy-base/libra-worker
    - order: 999 

/etc/init/libra-worker.conf:
  file:
    - managed
    - source: salt://lbaas-haproxy-base/libra-worker.conf
    - order: 999 

/etc/sudoers:
  file:
    - managed
    - source: salt://lbaas-haproxy-base/sudoers
    - user: root
    - mode: 400
    - order: 2

/mnt/log:
  file.directory:
  - user: haproxy
  - group: haproxy
  - mode: 755
  - makedirs: True
  - order: 5

/etc/rsyslog.d/10-haproxy.conf:
  file:
    - managed
    - source: salt://lbaas-haproxy-base/10-haproxy.conf
    - order: 6

/etc/logrotate.d/haproxy:
  file:
    - managed
    - source: salt://lbaas-haproxy-base/haproxy_logrotate.conf
    - order: 6

/etc/default/haproxy:
  file:
    - managed
    - source: salt://lbaas-haproxy-base/haproxy
    - order: 6

/etc/beaver.cfg:
  file:
    - managed
    - template: jinja
    - source: salt://lbaas-haproxy-base/beaver.cfg
