# installs jq directly from github. Example:
# https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64
#
{%- set version = '1.5' %}
{%- set base_url = 'https://github.com/stedolan/jq/releases/download' %}
{%- set release_bin = 'jq-linux64' %}
{%- set release_url = base_url + '/' + 'jq-' + version + '/' + release_bin %}
{%- set bin_path = '/usr/local/bin/jq' %}
{%- set checksum = 'aaa016d57ab8351360d02186809ade9cdecd3eb20df7a8cf05cd5d1037c4d36efae9e1bb0102d175c91b530b0309f24b48d579544249da7cbd50f721332617b9' %}


jq-release:
  file.managed:
    - name: {{ bin_path }}-{{ version }}
    - source: {{ release_url }}
    - source_hash: sha512={{ checksum }}
    - user: root
    - group: root
    - mode: 755

jq-bin:
  file.symlink:
    - name: {{ bin_path }}
    - target: {{ bin_path }}-{{ version }}
    - require:
        - file: jq-release
  cmd.run:
    - name: jq --version
    - require:
        - file: jq-bin
