# setup static files for consul webui

{% from "consul/checksum_map.jinja" import webui_checksum_map with context %}
{%- set default_version = '0.6.4' %}
{%- set version = salt['pillar.get']('consul:version', default_version) %}
{%- set default_checksum = webui_checksum_map[version] %}
{%- set checksum = salt['pillar.get']('consul:checksum', default_checksum) %}
{%- set default_base_url = 'https://releases.hashicorp.com' %}
{%- set base_url = salt['pillar.get']('consul:base_url', default_base_url) %}
{%- set home = '/home/consul' %}
{%- set app = 'consul' %}
{%- set user = app %}
{%- set webui_root = home ~ '/webui-' ~ version %}
{%- set webui_archive = app ~ '_' ~ version ~ '_web_ui.zip' %}
{%- set release_url = base_url ~ '/' ~ app ~ '/' ~ version ~ '/' ~ webui_archive %}

include:
  - consul.service


consul-webui-archive:
  archive.extracted:
    - name: {{ webui_root }}
    - source: {{ release_url }}
    - source_hash: sha512={{ checksum }}
    - if_missing: {{ webui_root }}/consul
    - archive_format: zip
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
