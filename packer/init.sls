# installs Packer from .zip archive. Example:
# https://dl.bintray.com/mitchellh/packer/packer_0.7.5_linux_amd64.zip
#
{%- set version = '0.7.5' %}
{%- set base_url = 'https://dl.bintray.com/mitchellh/packer/' %}
{%- set release_archive = 'packer_' + version + '_linux_amd64.zip' %}
{%- set release_url = base_url + release_archive %}
{%- set bin_path = '/usr/local/bin/packer' %}
{%- set checksum = 'f56a5cd689dfb9947d30870723e4dab492a83b342fdd202c3c763de716aba8397ffbcc7485c238eb6944c116adddb05653deb3e84b41630ffb2fcf1bb5b29e00' %}

include:
  - apps.unzip


packer-bin:
  archive.extracted:
    - name: {{ bin_path }}-{{ version }}
    - source: {{ release_url }}
    - source_hash: sha512={{ checksum }}
    - if_missing: {{ bin_path }}-{{ version }}/packer
    - archive_format: zip
    - require:
        - pkg: unzip
  file.symlink:
    - name: {{ bin_path }}
    - target: {{ bin_path }}-{{ version }}/packer
    - require:
        - archive: packer-bin

