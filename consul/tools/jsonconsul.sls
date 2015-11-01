# installs jsonconsul util from .tar.gz archive (release on github). Example:
# https://github.com/vsco/jsonconsul/releases/download/v0.4.0/jsonconsul_v0.4.0_linux_amd64.tar.gz
#
{%- set version = 'v0.4.0' %}
{%- set base_url = 'https://github.com/vsco/jsonconsul/releases/download/' %}
{%- set release_archive = version ~ '/jsonconsul_' ~ version ~ '_linux_amd64.tar.gz' %}
{%- set release_url = base_url ~ release_archive %}
{%- set bin_path = '/usr/local/bin/jsonconsul' %}
{%- set checksum = 'adb2dfc2ad00e15c3bc0de86080a478a8d23bb55efec7ac70749c01c619a11f8ff148691678e917e8d7ef6c8998821a4f5db84f0238a558c1ef4d6073bf3aab5' %}


# unpack the release archive from github/etc
jsonconsul-archive:
  archive.extracted:
    - name: {{ bin_path }}-{{ version }}
    - source: {{ release_url }}
    - source_hash: sha512={{ checksum }}
    - if_missing: {{ bin_path }}-{{ version }}/jsonconsul
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
        - archive: jsonconsul-archive

# create a symlink to the version of the binary that is active
jsonconsul-active-bin:
  file.symlink:
    - name: {{ bin_path }}
    - target: {{ bin_path }}-{{ version }}/jsonconsul
    - require:
        - file: jsonconsul-archive


jsonconsul-bin:
  # this is just a permissions check for the binary
  file.managed:
    - name: {{ bin_path }}
    - replace: False
    - mode: 755
    - user: root
    - group: root
    - require:
        - file: jsonconsul-active-bin
  # this confirms our success
  cmd.run:
    - name: 'jsonconsul --version'
    - require:
        - file: jsonconsul-bin
