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

libra_poolmgm_config:
  file:
    - managed
    - name: /etc/libra/libra.cfg
    - template: jinja
    - source: salt://lbaas-poolmgm/libra.cfg
    - order: 0

/etc/libra/logging_poolmgm.cfg:
  file:
    - managed
    - mode: 755
    - source: salt://lbaas-poolmgm/logging_poolmgm.cfg
    - owner: libra
    - group: libra
    - order: 0

libra_poolmgm_defaults:
  file:
    - managed
    - name: /etc/default/libra-poolmgm
    - source: salt://lbaas-poolmgm/libra-pool-mgm
    - order: last

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

libra_poolmgm_datadog_config:
  file:
    - managed
    - name: /etc/dd-agent/datadog.conf
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
libra_poolmgm_beaver_config:
  file:
    - managed
    - name: /etc/beaver.cfg
    - template: jinja
    - source: salt://lbaas-poolmgm/beaver.cfg
{% endif %}
