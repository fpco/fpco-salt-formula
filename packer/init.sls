# installs Packer from .zip archive. Example:
# https://releases.hashicorp.com/packer/packer_0.7.5_linux_amd64.zip
#
{% from "packer/checksum_map.jinja" import packer_checksum_map with context %}
{%- set default_version = '0.7.5' %}
{%- set version = salt['pillar.get']('packer:version', default_version) %}
{%- set default_checksum = packer_checksum_map[version] %}
{%- set checksum = salt['pillar.get']('packer:checksum', default_checksum) %}
{%- set default_base_url = 'https://releases.hashicorp.com' %}
{%- set base_url = salt['pillar.get']('packer:base_url', default_base_url) %}
{%- set app = 'packer' %}
{%- set release_archive = app ~ '_' ~ version ~ '_linux_amd64.zip' %}
{%- set release_url = base_url ~ '/' ~ app ~ '/' ~ version ~ '/' ~ release_archive %}
{%- set bin_path = '/usr/local/bin/' ~ app %}

include:
  - apps.unzip


packer-bin:
  archive.extracted:
    - name: {{ bin_path }}-{{ version }}
    - source: {{ release_url }}
    - source_hash: sha512={{ checksum }}
    - if_missing: {{ bin_path }}-{{ version }}/{{ app }}
    - archive_format: zip
    - require:
        - pkg: unzip
  file.symlink:
    - name: {{ bin_path }}
    - target: {{ bin_path }}-{{ version }}/{{ app }}
    - require:
        - archive: packer-bin

