# consul configs for the registry tier
{%- set private_ip = salt['cmd.run']('ec2metadata --local-ipv4') %}
{%- set host_ip = salt['pillar.get']('docker_registry:ip', private_ip) %}
{%- set user = 'consul' %}
{%- set consul_conf_path = '/home/consul/conf.d' %}

include:
  - consul.reload


registry-tier-consul-watch:
  file.managed:
    - name: {{ consul_conf_path }}/registry-tier-pillar-watch.json
    - user: {{ user }}
    - group: {{ user }}
    - mode: 640
    - contents: |
        {
            "watches": [
                {
                  "type": "keyprefix",
                  "prefix": "salt/roles/registry/docker/registry/",
                  "handler": "sudo salt-call --local state.sls docker.registry"
                }
            ]
        }
    - watch_in:
        - cmd: consul-service-check-reload


consul-service-config-registry-tier:
  file.managed:
    - name: {{ consul_conf_path }}/registry-tier-check.json
    - source: salt://consul/files/service.json
    - template: jinja
    - user: {{ user }}
    - group: {{ user }}
    - mode: 640
    - makedirs: True
    - context:
        name: registry
        tags:
          - registry
        address: {{ host_ip }}
        port: 5000
        check:
          script: 'curl {{ host_ip }}:5000/ >/dev/null 2>&1'
          interval: '30s'
    - watch_in:
        - cmd: consul-service-check-reload
