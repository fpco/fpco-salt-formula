# create service definition and check config for SSH

{%- set home = '/home/consul' %}
{%- set user = 'consul' %}

include:
  - consul
  - consul.services


consul-service-ssh:
  file.managed:
    - name: {{ home }}/conf.d/ssh.json
    - source: salt://consul/files/service.json
    - template: jinja
    - user: {{ user }}
    - group: {{ user }}
    - mode: 640
    - context:
        name: ssh
        tags:
          - ssh
        port: 22
        check:
          script: 'true'
          interval: '30s'
    - require:
        - user: consul-user
        - file: consul-conf-d
    - watch_in:
        - cmd: consul-service-reload
