# installs Terraform from .zip archive. Example:
# https://dl.bintray.com/mitchellh/terraform/terraform_0.4.2_linux_amd64.zip
#
{%- set version = '0.6.4' %}
{%- set base_url = 'https://dl.bintray.com/mitchellh/terraform/' %}
{%- set release_archive = 'terraform_' + version + '_linux_amd64.zip' %}
{%- set release_url = base_url + release_archive %}
{%- set bin_path = '/usr/local/bin/terraform' %}
{%- set checksum = '418afd8d9e7bfa6c1ecc1e472701d03675aaf5394daf699237d50102d766c9ddcff9e55e6418c7ce8ddb676704aa500ac68cd136f9e9efc8d77d7147e1ebd867' %}

include:
  - apps.unzip


terraform-archive:
  archive.extracted:
    - name: {{ bin_path }}-{{ version }}
    - source: {{ release_url }}
    - source_hash: sha512={{ checksum }}
    - if_missing: {{ bin_path }}-{{ version }}/terraform
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
    - target: {{ bin_path }}-{{ version }}/terraform
    - require:
        - file: terraform-archive

