# setup prom node_exporter as a service

{%- set os_release = salt['grains.get']('oscodename') %}
{%- set hostname = salt['grains.get']('id') %}
{%- set default_ip = salt['grains.get']('ipv4')[1] %}
{%- set ip = salt['pillar.get']('node_exporter:ip', default_ip) %}
{%- set args = salt['pillar.get']('node_exporter:args', '') %}
{%- set port = salt['pillar.get']('node_exporter:port', '9100') %}

{%- if os_release == 'trusty' %}
  {%- set service_config = '/etc/init/node_exporter.conf' %}
  {%- set service_tpl = 'salt://upstart/files/generic.conf' %}
{%- else %}
  {%- set service_config = '/etc/systemd/system/node_exporter.service' %}
  {%- set service_tpl = 'salt://systemd/files/basic.service.tpl' %}
{%- endif %}

include:
  - consul.reload

node_exporter-service:
  file.managed:
    - name: {{ service_config }}
    - source: {{ service_tpl }}
    - mode: 640
    - user: root
    - group: root
    - template: jinja
    - defaults:
        description: "Run prometheus' node_exporter executable directly"
        bin_path: /usr/local/bin/node_exporter
        bin_opts: {{ args }}
        runas_user: root
        runas_group: root
        respawn: True
  service.running:
    - name: node_exporter
    - enable: True
    - watch:
        - file: node_exporter-service


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
