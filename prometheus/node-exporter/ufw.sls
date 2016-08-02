{%- set port = salt['pillar.get']('node_exporter:port', '9100') %}

node-exporter-ufw-app-config:
  file.managed:
    - name: /etc/ufw/applications.d/node-exporter
    - source: salt://ufw/files/etc/ufw/applications.d/app_config.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 640
    - context:
        app: node-exporter
        title: node-exporter
        description: Prometheus Node Exporter (collect stats for prom server to pull)
        ports: {{ port }}
  cmd.run:
    - name: 'ufw allow node-exporter'
    - watch:
        - file: node-exporter-ufw-app-config
