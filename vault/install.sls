# installs vault from .zip archive. Example:
# https://releases.hashicorp.com/vault/0.3.1/vault_0.3.1_linux_amd64.zip
#
{% from "vault/checksum_map.jinja" import vault_checksum_map with context %}
{%- set default_version = '0.11.3' %}
{%- set version = salt['pillar.get']('vault:version', default_version) %}
{%- set default_checksum = vault_checksum_map[version] %}
{%- set checksum = salt['pillar.get']('vault:checksum', default_checksum) %}
{%- set base_url = 'https://releases.hashicorp.com' %}
{%- set app = 'vault' %}
{%- set release_archive = app ~ '_' ~ version ~ '_linux_amd64.zip' %}
{%- set release_url = base_url ~ '/' ~ app ~ '/' ~ version ~ '/' ~ release_archive %}
# set release_url = 'salt://vault/files/' ~ release_archive
{%- set bin_path = '/usr/local/bin/' ~ app %}

include:
  - apps.unzip
  - .user

vault-archive:
  archive.extracted:
    - name: {{ bin_path }}-{{ version }}
    - source: {{ release_url }}
    - source_hash: sha512={{ checksum }}
    - if_missing: {{ bin_path }}-{{ version }}/{{ app }}
    - archive_format: zip
    - enforce_toplevel: False
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
        - archive: vault-archive

vault-bin:
  file.symlink:
    - name: {{ bin_path }}
    - target: {{ bin_path }}-{{ version }}/{{ app }}
    - require:
        - file: vault-archive

# see https://vaultproject.io/docs/config/index.html
vault-enable-mlock:
  cmd.run:
    - name: "setcap cap_ipc_lock=+ep $(readlink -f $(which vault))"
    - require:
        - file: vault-bin
