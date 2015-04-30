# installs Terraform from .zip archive. Example:
# https://dl.bintray.com/mitchellh/terraform/terraform_0.4.2_linux_amd64.zip
#
{%- set version = '0.4.2' %}
{%- set base_url = 'https://dl.bintray.com/mitchellh/terraform/' %}
{%- set release_archive = 'terraform_' + version + '_linux_amd64.zip' %}
{%- set release_url = base_url + release_archive %}
{%- set bin_path = '/usr/local/bin/terraform' %}
{%- set checksum = 'a7bbaa70ac78d514c7f82ac44823db9484724ebb8b618fe36a7ec505486c7e5b08b7a19c744a300b643fc8317472755e04b277b5425285cf48bf119725e91182' %}

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

