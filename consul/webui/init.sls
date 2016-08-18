# setup static files for consul webui

{%- set home = '/home/consul' %}
{%- set user = 'consul' %}
{%- set version = '0.6.4' %}
{%- set webui_root = home ~ '/webui-' ~ version %}
{%- set base_url = 'https://releases.hashicorp.com/consul/' ~ version %}
{%- set webui_archive = 'consul_' ~ version ~ '_web_ui.zip' %}
{%- set release_url = base_url ~ '/' ~ webui_archive %}
{%- set checksum = '136405701769100cdd6362b718630cfd3bf305a315e8ff91dd38cdf8e6c82fda8f24500225f4aee76165d39ba935ef79096d4f8ac553ca3b76a7abbaae4740b4' %}

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
