# setup static files for consul webui

{%- set home = '/home/consul' %}
{%- set user = 'consul' %}
{%- set version = '0.5.2' %}
{%- set webui_root = home + '/webui-' + version %}
{%- set base_url = 'https://dl.bintray.com/mitchellh/consul/' %}
{%- set webui_archive = version + '_web_ui.zip' %}
{%- set release_url = base_url + webui_archive %}
{%- set checksum = '38c763773bec6e5f7e8b0765bdae875afa8477b99e544a8b685b14a23520c2409c8b885e8ec7abcd7574cd6be2dd836f28b1aa670bd8c10ada872bd4d63a445c' %}

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
