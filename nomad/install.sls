# installs nomad from .zip archive. Example:
# https://releases.hashicorp.com/nomad/0.1.2/nomad_0.1.2_linux_amd64.zip
#
{%- set version = '0.1.2' %}
{%- set base_url = 'https://releases.hashicorp.com' %}
{%- set app = 'nomad' %}
{%- set release_archive = app ~ '_' ~ version ~ '_linux_amd64.zip' %}
{%- set release_url = base_url ~ '/' ~ app ~ '/' ~ version ~ '/' ~ release_archive %}
{%- set bin_path = '/usr/local/bin/' ~ app %}
{%- set checksum = '8c6c447d8ca568720baa8fb5655e7e027f428331086c31c1daf52b681d9a5395b9de7106fa1172ed25546d5b6618845174145ad71fc30d52a43f758753c61d98' %}

include:
  - apps.unzip
  - nomad.user


nomad-archive:
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
        - archive: nomad-archive

nomad-bin:
  file.symlink:
    - name: {{ bin_path }}
    - target: {{ bin_path }}-{{ version }}/{{ app }}
    - require:
        - file: nomad-archive
