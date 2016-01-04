salt-master:
  service.running:
    - enable: {{ salt['pillar.get']('enable_master_on_boot', True) }}
