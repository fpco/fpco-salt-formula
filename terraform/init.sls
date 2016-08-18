# installs Terraform from .zip archive. Example:
# https://dl.bintray.com/mitchellh/terraform/terraform_0.4.2_linux_amd64.zip
#
{%- set version = '0.6.16' %}
{%- set base_url = 'https://releases.hashicorp.com' %}
{%- set app = 'terraform' %}
{%- set release_archive = app ~ '_' ~ version ~ '_linux_amd64.zip' %}
{%- set release_url = base_url ~ '/' ~ app ~ '/' ~ version ~ '/' ~ release_archive %}
{%- set bin_path = '/usr/local/bin/' ~ app %}
{%- set checksum = '40fdfc999430c002dd5c88d6613aa91dab6c376cbf0b93e7ddb620aad292718bd85cdefd164470042f717b03764381361e855bddd346c50ca1b5a3a7b4a69a67' %}

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

