# manage the consul config file, leave dependents to consul.init

{%- set home = '/home/consul' %}
{%- set user = 'consul' %}

include:
  - consul.user


consul-config:
  file.managed:
    - name: {{ home }}/conf.d/00-config.json
    - source: salt://consul/files/config.json
    - user: {{ user }}
    - group: {{ user }}
    - mode: 640
    - template: jinja
    - require:
        - user: consul-user
        - file: consul-user


