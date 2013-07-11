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



    
