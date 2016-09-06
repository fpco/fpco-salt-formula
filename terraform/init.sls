# installs Terraform from .zip archive. Example:
# https://dl.bintray.com/mitchellh/terraform/terraform_0.4.2_linux_amd64.zip
#
{% from "terraform/checksum_map.jinja" import terraform_checksum_map with context %}
{%- set default_version = '0.7.1' %}
{%- set version = salt['pillar.get']('terraform:version', default_version) %}
{%- set default_checksum = terraform_checksum_map[version] %}
{%- set checksum = salt['pillar.get']('terraform:checksum', default_checksum) %}
{%- set base_url = 'https://releases.hashicorp.com' %}
{%- set app = 'terraform' %}
{%- set release_archive = app ~ '_' ~ version ~ '_linux_amd64.zip' %}
{%- set release_url = base_url ~ '/' ~ app ~ '/' ~ version ~ '/' ~ release_archive %}
{%- set bin_path = '/usr/local/bin/' ~ app %}

include:
  - apps.unzip


terraform-archive:
  archive.extracted:
    - name: {{ bin_path }}-{{ version }}
    - source: {{ release_url }}
    - source_hash: sha512={{ checksum }}
    - if_missing: {{ bin_path }}-{{ version }}/{{ app }}
    - archive_format: zip
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
        - archive: terraform-archive

terraform-bin:
  file.symlink:
    - name: {{ bin_path }}
    - target: {{ bin_path }}-{{ version }}/{{ app }}
    - require:
        - file: terraform-archive

