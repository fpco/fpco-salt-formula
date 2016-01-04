salt-master:
  service.dead:
    - enable: {{ salt['pillar.get']('enable_master_on_boot', False) }}
