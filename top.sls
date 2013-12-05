stage:
    '*stage*':
      - common_logging
      - common_admin
    'lbaas-stage-api*':
      - lbaas-pyapi
      - common_gearman
    'lbaas-stage-api*':
      - lbaas-pyapi
      - common_gearman
    'lbaas-stage*poolmgm*':
      - lbaas-poolmgm
      - common_gearman
    'lbaas-stage-gearman*':
      - lbaas-gearman
    'lbaas-stage*mysql*':
      - lbaas-galera
    'lbaas-stage*haproxy*base*':
      - lbaas-haproxy-base
      - common_gearman
    'lbaas-stage*logstash*':
      - logstash
    'lbaas-stage*galera*':
      - lbaas-galera
    'lbaas-stage-stressor*':
      - lbaas-stressor
    'lbaas-test-web*':
      - lbaas-web
    'lbaas-test-web*':
      - lbaas-web
    '*stage*saltmaster*':
      - lbaas-saltmaster
    '*test*saltmaster*':
      - lbaas-saltmaster

