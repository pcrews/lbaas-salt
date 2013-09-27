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

{% if pillar['use_beaver'] == 'True' %}
/etc/beaver.cfg:
  file:
    - managed
    - template: jinja
    - source: salt://lbaas-poolmgm/beaver.cfg
{% endif %}
