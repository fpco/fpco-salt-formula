salt-minion:
  service.dead:
    - enable: {{ salt['pillar.get']('enable_minion_on_boot', False) }}
