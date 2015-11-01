# installs consul-cli util from .tar.gz archive (release on github). Example:
# https://github.com/vsco/consul-cli/releases/download/v0.4.0/consul-cli_v0.4.0_linux_amd64.tar.gz
#
{%- set version = '0.1.0' %}
{%- set base_url = 'https://github.com/CiscoCloud/consul-cli/releases/download' %}
{%- set release_archive = version ~ '/consul-cli_' ~ version ~ '_linux_amd64.tar.gz' %}
{%- set release_url = base_url ~ '/v' ~ release_archive %}
{%- set bin_path = '/usr/local/bin/consul-cli' %}
{%- set checksum = 'ac0c14e7143be86e69a338dd1b97ff7139956766d1cd975e39ceae69148cff1e8090a1636f303b2dd738178f92eeb2903a07005f89248149200ed81616dbc595' %}


# unpack the release archive from github/etc
consul-cli-archive:
  archive.extracted:
    - name: {{ bin_path }}-{{ version }}
    - source: {{ release_url }}
    - source_hash: sha512={{ checksum }}
    - if_missing: {{ bin_path }}-{{ version }}/consul-cli
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
        - archive: consul-cli-archive

# create a symlink to the version of the binary that is active
consul-cli-active-bin:
  file.symlink:
    - name: {{ bin_path }}
    - target: {{ bin_path }}-{{ version }}/consul-cli
    - require:
        - file: consul-cli-archive


consul-cli-bin:
  # this is just a permissions check for the binary
  file.managed:
    - name: {{ bin_path }}
    - replace: False
    - mode: 755
    - user: root
    - group: root
    - require:
        - file: consul-cli-active-bin
  # this confirms our success
  cmd.run:
    - name: 'consul-cli --version'
    - require:
        - file: consul-cli-bin
