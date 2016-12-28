# this formula installs the 's3gof3r' tool from github
{% from "apps/s3gof3r/checksum_map.jinja" import checksum_map with context %}

{%- set default_version = '0.5.0' %}
{%- set version = salt['pillar.get']('s3gof3r:version', default_version) %}

{%- set default_checksum = checksum_map[version] %}
{%- set checksum = salt['pillar.get']('s3gof3r:checksum', default_checksum) %}

{%- set app = 'gof3r' %}
{%- set base_url = 'https://github.com/rlmcpherson/s3gof3r/releases/download' %}
{%- set release_archive = app ~ '_' ~ version ~ '_linux_amd64.tar.gz' %}
{%- set release_url = base_url ~ '/' 'v' ~ version ~ '/' ~ release_archive %}

{%- set bin_path = '/usr/local/bin/' ~ app %}

gof3r-archive:
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
  archive.extracted:
    - name: {{ bin_path }}-{{ version }}
    - source: {{ release_url }}
    - source_hash: sha512={{ checksum }}
    - if_missing: {{ bin_path }}-{{ version }}/{{ app }}
    - archive_format: tar
    - tar_options: 'zvp --strip-components=1'
    - require:
        - file: gof3r-archive
  cmd.run:
    - name: {{ app }} --version
    - require:
        - file: gof3r-symlink

gof3r-symlink:
  file.symlink:
    - name: {{ bin_path }}
    - target: {{ bin_path }}-{{ version }}/{{ app }}
    - mode: 755
    - force: True
    - require:
        - archive: gof3r-archive
