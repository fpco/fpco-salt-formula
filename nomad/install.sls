# installs nomad from .zip archive. Example:
# https://releases.hashicorp.com/nomad/0.1.2/nomad_0.1.2_linux_amd64.zip
#
{% from "nomad/checksum_map.jinja" import nomad_checksum_map with context %}
{%- set default_version = '0.10.2' %}
{%- set version = salt['pillar.get']('nomad:version', default_version) %}
{%- set default_checksum = nomad_checksum_map[version] %}
{%- set checksum = salt['pillar.get']('nomad:checksum', default_checksum) %}
{%- set default_base_url = 'https://releases.hashicorp.com' %}
{%- set base_url = salt['pillar.get']('nomad:base_url', default_base_url) %}
{%- set app = 'nomad' %}
{%- set release_archive = app ~ '_' ~ version ~ '_linux_amd64.zip' %}
{%- set release_url = base_url ~ '/' ~ app ~ '/' ~ version ~ '/' ~ release_archive %}
{%- set bin_path = '/usr/local/bin/' ~ app %}

include:
  - apps.unzip
  - nomad.user


nomad-archive:
  archive.extracted:
    - name: {{ bin_path }}-{{ version }}
    - source: {{ release_url }}
    - source_hash: {{ checksum }}
    - if_missing: {{ bin_path }}-{{ version }}/{{ app }}
    - archive_format: zip
    - enforce_toplevel: False
    - require:
        - pkg: unzip
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
        - archive: nomad-archive

nomad-bin:
  file.symlink:
    - name: {{ bin_path }}
    - target: {{ bin_path }}-{{ version }}/{{ app }}
    - require:
        - file: nomad-archive

nomad-alias-conf:
  file.managed:
    - name: /etc/profile.d/nomad-alias.sh
    - user: root
    - group: root
    - mode: 755
    - contents: |
          #!/usr/bin/env bash

          alias ns='nomad status'
          alias nas='nomad alloc-status'
          alias nns='nomad node-status'
          alias nr='nomad run'
          alias n='nomad stop'
          alias nfc='nomad fs cat'
          alias n='nomad fs ls'
