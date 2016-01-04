include:
  - salt.minion.config

salt-minion:
  service.running:
    - enable: {{ salt['pillar.get']('enable_minion_on_boot', True) }}
    - watch:
        - file: salt-minion-id
        - file: salt-minion-config
