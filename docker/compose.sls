# install docker-compose from github
{% from "docker/compose_map.jinja" import compose_checksum_map with context %}

{%- set default_version = '1.7.1' %}
{%- set version = salt['pillar.get']('docker-compose:version', default_version) %}
{%- set default_checksum = compose_checksum_map[version] %}
{%- set checksum = salt['pillar.get']('docker-compose:checksum', default_checksum) %}
{%- set bin_path = '/usr/local/bin/docker-compose' %}
{%- set release_url = 'https://github.com/docker/compose/releases/download/' ~ version ~ '/docker-compose-Linux-x86_64' %}

compose-executable:
  file.managed:
    - name: {{ bin_path }}-{{ version }}
    - source: {{ release_url }}
    - source_hash: sha512={{ checksum }}
    - user: root
    - mode: 755

compose-symlink:
  file.symlink:
    - name: {{ bin_path }}
    - target: {{ bin_path }}-{{ version }}
    - require:
        - file: compose-executable
