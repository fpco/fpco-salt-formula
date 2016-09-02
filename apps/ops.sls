# this formula installs the generic 'ops' tool created and distributed by FPC

{%- set base_url = 'https://download.fpcomplete.com/dev-tools' %}
{%- set release_url = base_url ~ '/' ~ release_archive %}
{%- set bin_path = '/usr/local/bin/ops' %}

ops-bin:
  archive.extracted:
    - name: {{ bin_path }}
    - source_hash: sha512={{ checksum }}
    - if_missing: {{ bin_path }}
    - archive_format: tgz
