# create service definition and check config for the vault agent/server

{%- set consul_conf = '/home/consul' %}
{%- set user = 'consul' %}
{%- set default_ip = salt['grains.get']('ip4_interfaces')['eth0'][0] %}
{%- set http_ip = salt['pillar.get']('vault:ip', default_ip) %}
{%- set http_port = salt['pillar.get']('vault:port', '8200') %}

include:
  - consul.reload


{%- set token = salt['pillar.get']('vault:consul:token', 'CONSUL_TOKEN_HERE') %}
# "http": "http://{{ http_ip }}:{{ http_port }}/v1/sys/health/?token={{ token }}",
consul-service-vault-server:
  file.managed:
    - name: {{ consul_conf }}/conf.d/vault-server.json
    - user: {{ user }}
    - group: {{ user }}
    - mode: 640
    - contents: |
        {
          "service": {
            "name": "vault",
            "tags": ["vault"],
            "address": "{{ http_ip }}",
            "port": {{ http_port }},
            "checks": [
              {
                "script": "service vault status",
                "interval": "30s"
              }
            ]
          }
        }
    - watch_in:
        - cmd: consul-service-check-reload
