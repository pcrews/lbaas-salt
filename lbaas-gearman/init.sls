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

required_packages:
  pkg.installed:
    - pkgs:
      - gearman-job-server 
      - gearman-tools 
    - order: 1

/etc/default/gearman-job-server:
  file:
    - managed
    - source: salt://lbaas-gearman/gearman-job-server
    - order: 2

stop_gearman:
  cmd.run:
    - name: 'service gearman-job-server stop'
    - order: 5

start_gearman:
  cmd.run:
    - name: 'service gearman-job-server start '
    - order: last 



    
