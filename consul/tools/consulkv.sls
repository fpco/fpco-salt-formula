# installs consulkv util from .tar.gz archive (release on github). Example:
# https://github.com/vsco/consulkv/releases/download/v0.4.0/consulkv_v0.4.0_linux_amd64.tar.gz
#
{%- set version = '0.1.0' %}
{%- set base_url = 'https://github.com/spiritloose/consulkv/releases/download' %}
{%- set release_archive = version ~ '/consulkv_' ~ version ~ '_linux_amd64.tar.gz' %}
{%- set release_url = base_url ~ '/v' ~ release_archive %}
{%- set bin_path = '/usr/local/bin/consulkv' %}
{%- set checksum = '8094a3ecf4497120e4611cf8174beb27397201d57930e7c916f2b707cc5f1ef8743681e2e453f8ebcfadda17fed791f94a632cb115579515593b706f24cadf7d' %}


# unpack the release archive from github/etc
consulkv-archive:
  archive.extracted:
    - name: {{ bin_path }}-{{ version }}
    - source: {{ release_url }}
    - source_hash: sha512={{ checksum }}
    - if_missing: {{ bin_path }}-{{ version }}/consulkv
    - archive_format: tar
    - tar_options: 'zvp --strip-components=1'
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
        - archive: consulkv-archive

# create a symlink to the version of the binary that is active
consulkv-active-bin:
  file.symlink:
    - name: {{ bin_path }}
    - target: {{ bin_path }}-{{ version }}/consulkv
    - require:
        - file: consulkv-archive


consulkv-bin:
  # this is just a permissions check for the binary
  file.managed:
    - name: {{ bin_path }}
    - replace: False
    - mode: 755
    - user: root
    - group: root
    - require:
        - file: consulkv-active-bin
  # this confirms our success
  cmd.run:
    - name: 'consulkv --version || true'
    - require:
        - file: consulkv-bin
