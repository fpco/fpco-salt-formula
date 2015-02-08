# manage the consul config file, leave dependents to consul.init

{%- set consul = salt['pillar.get']('consul', {}) %}
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
        dc: us-east-1
        home: {{ home }}
        server: False
        ip: {{ salt['grains.get']('ip4_interfaces')['eth0'] }}
        leaders: {%- for leader_ip in consul['leaders'] %}
          - {{ leader_ip }}
          {% endfor %}
        secret_key: {{ consul['secret_key'] }}

    - require:
        - user: consul-user
        - file: consul-user


