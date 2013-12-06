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

libra_gearman_packages:
  pkg.installed:
    - pkgs:
      - gearman-job-server
      - gearman-tools
    - order: 0 

{% if pillar['use_datadog'] == True %}
install_datadog:
  cmd.run:
    - name: DD_API_KEY={{ pillar['lbaas_datadog_api_key'] }} bash -c "$(wget -qO- http://dtdg.co/agent-install-ubuntu)"
    - order: 2

libra_gearman_datadog_config
  file:
    - managed
    - name: /etc/dd-agent/datadog.conf
    - source: salt://lbaas-gearman/datadog.conf
    - order: 7
    
/usr/share/datadog/agent/checks.d/network.py:
  file:
    - managed
    - source: salt://lbaas-gearman/network.py
    - order: 7

/etc/ddagent/checks.d/network.yaml:
  file:
    - managed
    - source: salt://lbaas-gearman/network.yaml
    - order: 7

{% endif %}

{% if pillar['gearman_ssl'] == True %}
test_cmd:
  cmd.run:
    - name: "echo HEEELLLLOOOOOO SSL"

/etc/ssl/certs/gearmand-ca.pem:
  file:
    - managed
    - template: jinja
    - mode: 644
    - owner: gearman
    - group: gearman
    - source: salt://debian-packages/gearmand-ca.pem
    - order: 6

/etc/ssl/certs/gearmand.key:
  file:
    - managed
    - template: jinja
    - mode: 600
    - owner: gearman
    - group: gearman
    - source: salt://debian-packages/gearmand.key
    - order: 6

/etc/ssl/certs/gearmand.pem:
  file:
    - managed
    - template: jinja
    - mode: 644
    - owner: gearman
    - group: gearman
    - source: salt://debian-packages/gearmand.pem
    - order: 6

/etc/ssl/certs/gearman.key:
  file:
    - managed
    - template: jinja
    - mode: 600
    - owner: ubuntu
    - group: ubuntu
    - source: salt://debian-packages/gearman.key
    - order: 6

/etc/ssl/certs/gearman.pem:
  file:
    - managed
    - template: jinja
    - mode: 644
    - owner: ubuntu
    - group: ubuntu
    - source: salt://debian-packages/gearman.pem
    - order: 6
{% else %}
test_cmd2:
  cmd.run:
    - name: "echo NO SSL FOR YOU!!!!!!!!!!!!!!!!!!!!!!!"

{% endif %}

/etc/default/gearman-job-server:
  file:
    - managed
    - template: jinja
    - source: salt://lbaas-gearman/gearman-job-server
    - order: 6 

stop_gearman:
  cmd.run:
    - name: 'service gearman-job-server stop'
    - order: 7 

start_gearman:
  cmd.run:
    - name: 'service gearman-job-server start '
    - order: last 

{% if pillar['use_beaver'] == True %}
libra_gearman_beaver_config:
  file:
    - managed
    - name: /etc/beaver.cfg
    - template: jinja
    - source: salt://lbaas-gearman/beaver.cfg
    - order: 6
{% endif %}

