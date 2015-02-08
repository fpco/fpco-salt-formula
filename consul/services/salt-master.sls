
{%- set home = '/home/consul' %}
{%- set user = 'consul' %}

include:
  - consul
  - consul.services


consul-service-salt-master-publish:
  file.managed:
    - name: {{ home }}/conf.d/salt-master-publish.json
    - source: salt://consul/files/service.json
    - template: jinja
    - user: {{ user }}
    - group: {{ user }}
    - mode: 640
    - context:
        name: salt-master-publish
        tags:
          - salt
          - master
          - publish
        port: 4505
        check:
          script: 'true'
          interval: '30s'
    - require:
        - user: consul-user
        - file: consul-conf-d
    - watch_in:
        - cmd: consul-service-reload


consul-service-salt-master-ret:
  file.managed:
    - name: {{ home }}/conf.d/salt-master-ret.json
    - source: salt://consul/files/service.json
    - template: jinja
    - user: {{ user }}
    - group: {{ user }}
    - mode: 640
    - context:
        name: salt-master-ret
        tags:
          - salt
          - master
          - ret
        port: 4506
        check:
          script: 'true'
          interval: '30s'
    - require:
        - user: consul-user
        - file: consul-conf-d
    - watch_in:
        - cmd: consul-service-reload
