# manage the consul config file, leave dependents to consul.init

{%- set home = '/home/consul' %}
{%- set user = 'consul' %}
{%- set ip = salt['grains.get']('ip4_interfaces')['eth0'][0] %}

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
        home: {{ home }}
        server: False
        ip: {{ ip }}
    - require:
        - user: consul-user
        - file: consul-user


