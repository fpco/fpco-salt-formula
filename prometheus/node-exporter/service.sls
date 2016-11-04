{%- set hostname = salt['grains.get']('id') %}
{%- set default_ip = salt['grains.get']('ipv4')[1] %}
{%- set ip = salt['pillar.get']('node_exporter:ip', default_ip) %}
{%- set args = salt['pillar.get']('node_exporter:args', '') %}
{%- set port = salt['pillar.get']('node_exporter:port', '9100') %}

include:
  - consul.reload

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


node-exporter-consul-service:
  file.managed:
    - name: /home/consul/conf.d/node_exporter_service.json
    - user: consul
    - group: consul
    - mode: 640
    - contents: |
        {
          "service": {
            "id": "node-exporter-{{ hostname }}",
            "name": "node-exporter",
            "tags": [],
            "address": "{{ ip }}",
            "port": {{ port }},
            "checks": [
              {
                "script": "pgrep node_exporter",
                "interval": "30s"
              }
            ]
          }
        }
    - watch_in:
        - cmd: consul-service-check-reload
