# installs prometheus' node-exporter from .tar.gz archive. Example:
# https://github.com/prometheus/node_exporter/releases/download/0.12.0/node_exporter-0.12.0.linux-amd64.tar.gz
#
{% from "prometheus/node-exporter/checksum_map.jinja" import releases with context %}
{%- set default_version = '0.12.0' %}
{%- set version = salt['pillar.get']('node_exporter:version', default_version) %}
{%- set default_checksum = releases[version] %}
{%- set checksum = salt['pillar.get']('node_exporter:checksum', default_checksum) %}
{%- set base_url = 'https://github.com/prometheus/node_exporter/releases/download' %}
{%- set app = 'node_exporter' %}
{%- set arch = 'linux-amd64' %}
{%- set release_archive = app ~ '-' ~ version ~ '.linux-amd64.tar.gz' %}
{%- set release_url = base_url ~ '/' ~ version ~ '/' ~ release_archive %}
{%- set bin_path = '/usr/local/bin/' ~ app %}

include:
  - prometheus.node-exporter.ufw


node_exporter-archive:
  archive.extracted:
    - name: {{ bin_path }}-{{ version }}
    - source: {{ release_url }}
    - source_hash: sha512={{ checksum }}
    - if_missing: {{ bin_path }}-{{ version }}/{{ app }}
    - archive_format: tar
    - tar_options: 'z --strip-components=1'
  file.directory:
    - name: {{ bin_path }}-{{ version }}
    - user: root
    - group: root
    - file_mode: 755
    - dir_mode: 755
    - makedirs: True
    - recurse:
        - user
        - group
        - mode
    - require:
        - archive: node_exporter-archive

node_exporter-bin:
  file.symlink:
    - name: {{ bin_path }}
    - target: {{ bin_path }}-{{ version }}/{{ app }}
    - require:
        - file: node_exporter-archive
