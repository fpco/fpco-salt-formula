# create service definition and check config for the consul webui

{%- set home = '/etc/consul' %}
{%- set user = 'root' %}
{%- set group = 'consul' %}

include:
  - consul
  - consul.reload


consul-service-consul-webui:
  file.managed:
    - name: {{ home }} ~ '/conf.d/consul-webui.json'
    - source: salt://consul/files/service.json
    - template: jinja
    - user: {{ user }}
    - group: {{ group }}
    - mode: 640
    - context:
        name: consul-webui
        tags:
          - consul-webui
        address: 127.0.0.1
        port: 8500
        check:
          script: 'true'
          interval: '30s'
    - require:
        - user: consul-user
        - file: consul-conf-d
    - watch_in:
        - cmd: consul-service-check-reload
