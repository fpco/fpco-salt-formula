# this formula installs the generic 'ops' tool created and distributed by FPC

{% from "apps/ops/checksum_map.jinja" import ops_checksum_map with context %}

{%- set default_version = '0.1.1' %}
{%- set version = salt['pillar.get']('ops:version', default_version) %}

{%- set default_checksum = ops_checksum_map[version] %}
{%- set checksum = salt['pillar.get']('ops:checksum', default_checksum) %}

{%- set base_url = 'https://download.fpcomplete.com/ops' %}
{%- set release_archive = 'ops-v' ~ version ~ '-linux-amd64' %}
{%- set release_url = base_url ~ '/' ~ release_archive %}

{%- set bin_path = '/usr/local/bin/ops-v' ~ version ~ '/' ~ release_archive %}
{%- set sym_path = '/usr/local/bin/ops' %}

ops-bin:
  file.managed:
    - name: {{ bin_path }}
    - source: {{ release_url }}
    - source_hash: sha512={{ checksum }}
    - mode: 755
    - makedirs: True
    - force: True
  cmd.run:
    - name: ops --help
    - require:
        - file: ops-symlink

ops-symlink:
  file.symlink:
    - name: {{ sym_path }}
    - target: {{ bin_path }}
    - mode: 755
    - force: True
    - require:
        - file: ops-bin

