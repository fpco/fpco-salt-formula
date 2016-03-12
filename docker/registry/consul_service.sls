# consul configs for the registry tier
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
        port: 5000
        check:
          script: 'curl 0.0.0.0:5000/ >/dev/null 2>&1'
          interval: '30s'
    - watch_in:
        - cmd: consul-service-check-reload
