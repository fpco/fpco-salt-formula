# rkt pkg to install

{%- set rkt_checksum_map = {
        '1.29.0': 'bd216f3277b7793fb83923bea618810ec636e5542fd2a69b5a309bf35ed88c417d1d2241be102bcadc7a6a1f0d661cdc197bacaaa8119918aba472524a80ac49',
        }
%}
{%- set default_version = '1.29.0' %}
{%- set version = salt['pillar.get']('rkt:version', default_version) %}
{%- set default_checksum = rkt_checksum_map[version] %}
{%- set checksum = salt['pillar.get']('rkt:checksum', default_checksum) %}
{%- set default_base_url = 'https://github.com/rkt/rkt/releases/download/' %}
{%- set base_url = salt['pillar.get']('rkt:base_url', default_base_url) %}
{%- set app = 'rkt' %}
# https://github.com/rkt/rkt/releases/download/v1.29.0/rkt_1.29.0-1_amd64.deb         
{%- set deb_file = app ~ '_' ~ version ~ '-1_amd64.deb' %}
{%- set release_url = base_url ~ '/v' ~ version ~ '/' ~ deb_file %}
{%- set pkg_root = '/root' %}

{{ deb_file }}:
  file.managed:
    - name: {{ pkg_root }}/{{ deb_file }}
    - source: {{ release_url }}
    - source_hash: sha512={{ checksum }}
    - user: root
    - group: root
    - mode: 640
  cmd.run:
    - name: 'dpkg --install {{ pkg_root }}/{{ deb_file }}'
    - require:
        - file: {{ deb_file }}

