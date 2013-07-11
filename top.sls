stage:
    'lbaas-stage-pyapi-az*':
      - lbaas-pyapi
      - logging_common
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
    'lbaas-stage*logstash*':
      - logstash
    'lbaas-stage*galera*':
      - lbaas-galera
    'lbaas-stage-pyapi-haproxy*':
      - lbaas-pyapi-haproxy

