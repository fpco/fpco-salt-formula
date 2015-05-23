# installs Terraform from .zip archive. Example:
# https://dl.bintray.com/mitchellh/terraform/terraform_0.4.2_linux_amd64.zip
#
{%- set version = '0.5.1' %}
{%- set base_url = 'https://dl.bintray.com/mitchellh/terraform/' %}
{%- set release_archive = 'terraform_' + version + '_linux_amd64.zip' %}
{%- set release_url = base_url + release_archive %}
{%- set bin_path = '/usr/local/bin/terraform' %}
{%- set checksum = '2b33f9b148e4aaf5c2b019d1c6576f64a19a45a0400d3dc67bbeae4533195215b20b76a4f083097156035bf2795856aace7a700d71fe4ae4f0959b840a7e3ca9' %}

include:
  - unzip


terraform-bin:
  archive.extracted:
    - name: {{ bin_path }}-{{ version }}
    - source: {{ release_url }}
    - source_hash: sha512={{ checksum }}
    - if_missing: {{ bin_path }}-{{ version }}/terraform
    - archive_format: zip
    - require:
        - pkg: unzip
  file.symlink:
    - name: {{ bin_path }}
    - target: {{ bin_path }}-{{ version }}/terraform
    - require:
        - archive: terraform-bin

