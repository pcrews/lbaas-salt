stage:
    #'*stage*':
    '*':
      - common_logging
      - common_admin
    'lbaas-stage-pyapi-az*':
      - lbaas-pyapi
      - common_gearman
    'lbaas-stage-api*':
      - lbaas-pyapi
      - common_gearman
    'lbaas-stage*poolmgm*':
      - lbaas-poolmgm
    'lbaas-stage*gearman*':
      - lbaas-gearman
    'lbaas-stage*mysql*':
      - lbaas-mysql
    'lbaas-stage*statsd*':
      - lbaas-statsd
    'lbaas-stage*haproxy*base*':
      - lbaas-haproxy-base
      - common_gearman
    'lbaas-stage*logstash*':
      - logstash
    'lbaas-stage*galera*':
      - lbaas-galera
    'lbaas-stage-pyapi-haproxy*':
      - lbaas-pyapi-haproxy
    'lbaas-stage-stressor*':
      - lbaas-stressor
    'lbaas-stage-web*':
      - lbaas-web
    'lbaas-test-web*':
      - lbaas-web
    '*stage*saltmaster*':
      - lbaas-saltmaster
    '*test*saltmaster*':
      - lbaas-saltmaster

