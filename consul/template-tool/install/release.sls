# installs consul-template from .tar.gz archive. Example:
# https://github.com/hashicorp/consul-template/releases/download/v0.10.0/consul-template_0.10.0_linux_amd64.tar.gz
#
{%- set version = '0.11.1' %}
{%- set root = '/root' %}
{%- set install_to = '/usr/local/bin' %}
{%- set bin_path = install_to ~ '/consul-template' %}
{%- set base_url = 'https://releases.hashicorp.com/consul-template/' ~ version %}
{%- set archive_basename = 'consul-template_' ~ version ~ '_linux_amd64' %}
{%- set archive_filename = archive_basename ~ '.zip' %}
{%- set release_url = base_url ~ '/' ~ archive_filename %}
{%- set checksum = '57d9f07a004512910280b46b357c9d2dd2d810f822a6652c6ae7914f0642952b24c615a71b4a51da615c7789017498c340d61ec7eb935ee79ae966ef02c0c0ca' %}

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
