# create service definition and check config for the nomad agent/server

{%- set consul_conf = '/home/consul' %}
{%- set user = 'consul' %}
{%- set server = salt['pillar.get']('nomad:server', False) %}
{%- set service_ip = salt['grains.get']('ip4_interfaces')['eth0'][0] %}
{%- set http_port = 4646 %}
{%- set rpc_port = 4647 %}

include:
  - consul.reload


{%- if server %}
consul-service-nomad-server:
  file.managed:
    - name: {{ consul_conf }}/conf.d/nomad-server.json
    - user: {{ user }}
    - group: {{ user }}
    - mode: 640
    - contents: |
        {
          "service": {
            "name": "nomad-server",
            "tags": ["nomad-server"],
            "address": "{{ service_ip }}",
            "port": {{ rpc_port }},
            "checks": [
              {
                "http": "http://{{ service_ip }}:{{ http_port }}/v1/agent/self/",
                "interval": "30s"
              }
            ]
          }
        }
    - watch_in:
        - cmd: consul-service-check-reload
{%- else %}
consul-check-nomad-agent:
  file.managed:
    - name: {{ consul_conf }}/conf.d/nomad-agent-check.json
    - source: salt://consul/files/check_http.json
    - template: jinja
    - user: {{ user }}
    - group: {{ user }}
    - mode: 640
    - context:
        name: 'nomad-agent'
        url: 'http://{{ service_ip }}:{{ http_port }}/v1/agent/self/'
        timeout: '2s'
        interval: '30s'
    - watch_in:
        - cmd: consul-service-check-reload
{% endif %}
