# installs consul-template from .tar.gz archive. Example:
# https://github.com/hashicorp/consul-template/releases/download/v0.10.0/consul-template_0.10.0_linux_amd64.tar.gz
#
{%- set version = '0.12.2' %}
{%- set root = '/root' %}
{%- set install_to = '/usr/local/bin' %}
{%- set bin_path = install_to ~ '/consul-template' %}
{%- set base_url = 'https://releases.hashicorp.com/consul-template/' ~ version %}
{%- set archive_basename = 'consul-template_' ~ version ~ '_linux_amd64' %}
{%- set archive_filename = archive_basename ~ '.zip' %}
{%- set release_url = base_url ~ '/' ~ archive_filename %}
{%- set checksum = 'cae93fde050e7ef3abe2a1db75cc213afcf2bd10cb141a672e295b25212b562ce1205281804fa81b9ec93e606f9c42081563eeacca4b744bebee21e2b69f5363' %}

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
