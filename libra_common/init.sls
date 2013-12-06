libra_common_packages:
  pkg.installed:
    - pkgs:
      - git
      - python-pip
    - order: 1

add_ppa:
  cmd.run:
    - name: sudo add-apt-repository {{ pillar['lbaas_ppa'] }} 
    - order: 0 


update_apt:
  cmd.run:
    - name: 'apt-get update'
    - order: 2 
