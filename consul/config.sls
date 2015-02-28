# manage the consul config file, leave dependents to consul.init

{%- set c = salt['pillar.get']('consul', {}) %}
{%- set home = '/home/consul' %}
{%- set user = 'consul' %}

include:
  - consul


consul-config:
  file.managed:
    - name: {{ home }}/config.json
    - source: salt://consul/files/config.json
    - user: {{ user }}
    - group: {{ user }}
    - mode: 640
    - template: jinja
    - defaults:
        dc: {{ c['datacenter'] }}
        home: {{ home }}
        server: False
        ip: {{ salt['grains.get']('ip4_interfaces')['eth0'] }}
        secret_key: {{ c['secret_key'] }}
    - require:
        - user: consul-user
        - file: consul-user


