# setup static files for consul webui

{%- set home = '/home/consul' %}
{%- set user = 'consul' %}
{%- set version = '0.6.3' %}
{%- set webui_root = home ~ '/webui-' ~ version %}
{%- set base_url = 'https://releases.hashicorp.com/consul/' ~ version %}
{%- set webui_archive = 'consul_' ~ version ~ '_web_ui.zip' %}
{%- set release_url = base_url ~ '/' ~ webui_archive %}
{%- set checksum = 'ff93e4f7b373dae6412366fc241377d916baf4675b2113c2e289d337d3193f0ebbca7387e1fb783a38126f4e04d1d94c8b144d88fc326357d30dcf8b9ee3aaa5' %}

include:
  - consul.service


consul-webui-archive:
  archive.extracted:
    - name: {{ webui_root }}
    - source: {{ release_url }}
    - source_hash: sha512={{ checksum }}
    - if_missing: {{ webui_root }}/consul
    - archive_format: zip
    - require:
        - pkg: unzip
  file.directory:
    - name: {{ webui_root }}
    - user: root
    - group: consul
    - file_mode: 640
    - dir_mode: 750
    - makedirs: True
    - recurse:
        - user
        - group
        - mode
    - require:
        - archive: consul-webui-archive
        - user: consul-user
    - watch_in:
        - service: consul-upstart


consul-webui:
  file.symlink:
    - name: {{ home }}/webui
    - target: {{ webui_root }}
    - require:
        - archive: consul-webui-archive


extend:
  consul-upstart:
    file:
      - context:
          webui: True
