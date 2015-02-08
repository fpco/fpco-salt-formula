# setup static files for consul webui

{%- set home = '/home/consul' %}
{%- set user = 'consul' %}

include:
  - consul.agent


consul-webui:
  file.recurse:
    - name: {{ home }}/webui
    - source: salt://consul/files/webui
    - user: {{ user }}
    - group: {{ user }}
    - dir_mode: 750
    - file_mode: 640
    - require:
        - user: consul-user
    - watch_in:
        - service: consul-upstart


extend:
  consul-upstart:
    file:
      - context:
          webui: True
