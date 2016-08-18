# installs consul-template from .tar.gz archive. Example:
# https://github.com/hashicorp/consul-template/releases/download/v0.10.0/consul-template_0.10.0_linux_amd64.tar.gz
#

{% from "consul/template-tool/install/checksum_map.jinja" import consul_template_checksum_map with context %}
{%- set default_version = '0.12.2' %}
{%- set version = salt['pillar.get']('consul_template:version', default_version) %}
{%- set default_checksum = consul_template_checksum_map[version] %}
{%- set checksum = salt['pillar.get']('consul_template:checksum', default_checksum) %}
{%- set default_base_url = 'https://releases.hashicorp.com' %}
{%- set base_url = salt['pillar.get']('consul_template:base_url', default_base_url) %}
{%- set root = '/root' %}
{%- set install_to = '/usr/local/bin' %}
{%- set app = 'consul-template' %}
{%- set bin_path = install_to ~ '/' ~ app %}
{%- set release_archive = app ~ '_' ~ version ~ '_linux_amd64.zip' %}
{%- set release_url = base_url ~ '/' ~ app ~ '/' ~ version ~ '/' ~ release_archive %}

include:
  - apps.unzip


consul-template-archive:
  file.directory:
    - name: {{ bin_path }}-{{ version }}
    - user: root
    - group: root
    - mode: 755
    - makedirs: True
    - recurse:
        - user
        - group
        - mode
    - require:
        - archive: consul-template-archive
  archive.extracted:
    - name: {{ bin_path }}-{{ version }}
    - source: {{ release_url }}
    - source_hash: sha512={{ checksum }}
    - if_missing: {{ bin_path }}-{{ version }}/consul-template
    - archive_format: zip
    - require:
        - pkg: unzip


consul-template-bin:
  file.symlink:
    - name: {{ bin_path }}
    - target: {{ bin_path }}-{{ version }}/consul-template
    - require:
        - file: consul-template-archive
