{%- set args = salt['pillar.get']('node_exporter:args', '') %}

node_exporter-upstart:
  file.managed:
    - name: /etc/init/node_exporter.conf
    - source: salt://upstart/files/generic.conf
    - mode: 640
    - user: root
    - group: root
    - template: jinja
    - defaults:
        description: "Run prometheus' node-exporter executable directly"
        bin_path: /usr/local/bin/node_exporter
        bin_opts: {{ args }}
        runas_user: root
        runas_group: root
        respawn: True
  service.running:
    - name: node_exporter
    - enable: True
    - watch:
        - file: node_exporter-upstart


