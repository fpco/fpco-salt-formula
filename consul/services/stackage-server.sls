# create service check config for stackage-server

{%- set home = '/home/consul' %}
{%- set user = 'consul' %}

include:
  - consul
  - consul.services


consul-service-stackage-server:
  file.managed:
    - name: {{ home }}/conf.d/stackage-server.json
    - source: salt://consul/files/service.json
    - template: jinja
    - user: {{ user }}
    - group: {{ user }}
    - mode: 640
    - context:
        name: stackage-server
        tags:
          - stackage-server
          - web
        port: 3000
        check:
          script: 'true'
          interval: '30s'
    - require:
        - user: consul-user
        - file: consul-conf-d
    - watch_in:
        - cmd: consul-service-reload
