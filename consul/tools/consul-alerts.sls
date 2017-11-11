{% set checksum_map = {
  '0.3.2': 'cdc5fec1c37ffab783372bcd1696e2d31baa8f15feba09c750fa128544caaf90717d66e11daeaa9037868872fe460a4e17db073e87ca07cbdc148228d60f264e',
  '0.5.0': '6f4410a66a5fff3377b8cd02de4c1b72dfc881e4050184312678c6c001a402c9bd8d22400edc043e8e37feeadf22603bac7660c1c4e3f79f32419a4871782ee8',
  }
%}
{%- set default_version = '0.5.0' %}
{%- set version = salt['pillar.get']('consul_alerts:version', default_version) %}
{%- set default_checksum = checksum_map[version] %}
{%- set checksum = salt['pillar.get']('consul_alerts:checksum', default_checksum) %}
{%- set default_base_url = 'https://bintray.com/artifact/download/darkcrux/generic' %}
{%- set base_url = salt['pillar.get']('consul_alerts:base_url', default_base_url) %}
{%- set app = 'consul-alerts' %}
{%- set release_archive = app ~ '-latest-linux-amd64.tar' %}
{%- set release_url = base_url ~ '/' ~ release_archive %}
{%- set bin_path = '/usr/local/bin/' ~ app %}

consul-alerts-archive:
  archive.extracted:
    - name: {{ bin_path }}-{{ version }}
    - source: {{ release_url }}
    - source_hash: sha512={{ checksum }}
    - if_missing: {{ bin_path }}-{{ version }}/{{ app }}
    - archive_format: tar
    - tar_options: 'p'
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
        - archive: consul-alerts-archive

consul-alerts-bin:
  file.symlink:
    - name: {{ bin_path }}
    - target: {{ bin_path }}-{{ version }}/{{ app }}
    - require:
        - file: consul-alerts-archive
