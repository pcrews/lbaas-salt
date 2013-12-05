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

/etc/libra.cfg:
  file:
    - managed
    - template: jinja
    - source: salt://lbaas-poolmgm/libra.cfg
    - order: 0

libra_pool_mgm:
  pkg.installed:
    - pkgs:
      - libra-pool-mgm
    - order: 1

{% if pillar['use_datadog'] == True %}
install_datadog:
  cmd.run:
    - name: DD_API_KEY={{ pillar['lbaas_datadog_api_key'] }}  bash -c "$(wget -qO- http://dtdg.co/agent-install-ubuntu)"
    - order: 2

/etc/dd-agent/datadog.conf:
  file:
    - managed
    - template: jinja
    - source: salt://lbaas-poolmgm/datadog.conf
    - order: 7

/usr/share/datadog/agent/checks.d/testpid.py:
  file:
    - managed
    - source: salt://lbaas-poolmgm/testpid.py
    - order: 7

/etc/dd-agent/conf.d/testpid.yaml:
  file:
    - managed
    - source: salt://lbaas-poolmgm/testpid.yaml
    - order: 7 

/opt/pool_mgm_log.py:
  file:
    - managed
    - source: salt://lbaas-poolmgm/pool_mgm_log.py
    - order: 7
{% endif %}

{% if pillar['use_beaver'] == True %}
/etc/beaver.cfg:
  file:
    - managed
    - template: jinja
    - source: salt://lbaas-poolmgm/beaver.cfg
{% endif %}

/etc/ssl/galera-ca-cert.pem:
  file:
    - managed
    - mode: 600
    - source: salt://debian-packages/galera-ca-cert.pem
    - owner: root
    - group: root
   
/etc/ssl/galera-client-cert.pem:
  file:
    - managed
    - mode: 600
    - source: salt://debian-packages/galera-client-cert.pem
    - owner: root
    - group: root

/etc/ssl/galera-client-key.pem:
  file:
    - managed
    - mode: 600
    - source: salt://debian-packages/galera-client-key.pem
    - owner: root
    - group: root

