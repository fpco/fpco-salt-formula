# installs Terraform from .zip archive. Example:
# https://dl.bintray.com/mitchellh/terraform/terraform_0.4.2_linux_amd64.zip
#
{%- set version = '0.6.3' %}
{%- set base_url = 'https://dl.bintray.com/mitchellh/terraform/' %}
{%- set release_archive = 'terraform_' + version + '_linux_amd64.zip' %}
{%- set release_url = base_url + release_archive %}
{%- set bin_path = '/usr/local/bin/terraform' %}
{%- set checksum = '1988bf7f65f1876fd572bee9ea110105b56cb2e04b78c451373511831c459d521c6efc97fd66e67639b3ca7f374a4c9cc2d1df1b53c1964c3063be80dd834f18' %}

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

