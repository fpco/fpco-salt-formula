# installs Terraform from .zip archive. Example:
# https://dl.bintray.com/mitchellh/terraform/terraform_0.4.2_linux_amd64.zip
#
{%- set version = '0.6.11' %}
{%- set base_url = 'https://releases.hashicorp.com' %}
{%- set app = 'terraform' %}
{%- set release_archive = app ~ '_' ~ version ~ '_linux_amd64.zip' %}
{%- set release_url = base_url ~ '/' ~ app ~ '/' ~ version ~ '/' ~ release_archive %}
{%- set bin_path = '/usr/local/bin/' ~ app %}
{%- set checksum = '1a893c1fccdea4a0f32b4370eb1d3681e399a5cf063623f3a5978dcd04bb64915160ba56f9eb6cee3192c4e8667558b5111df74245ca9ae426427f14bbc57474' %}

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

