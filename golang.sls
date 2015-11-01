{%- set bin_path = '/usr/local' %}
{%- set version = '1.4.2' %}
{%- set go_path = bin_path ~ '/go' %}
{%- set release_url = 'https://storage.googleapis.com/golang/go' ~ version ~ '.linux-amd64.tar.gz' %}
{%- set checksum = 'ea9982698d306e98e8236de1515bbdc1bce7290f6db9f61c5171cb10ec6d4619361ba7108c1d4c58d269403ce32cc5de6c70859441da2e22b5cce0d4ebc69c7a' %}
{%- set go_executables = ['go', 'godoc', 'gofmt'] %}


golang-bin:
  archive.extracted:
    - name: {{ bin_path }}
    - source: {{ release_url }}
    - source_hash: sha512={{ checksum }}
    - if_missing: {{ go_path }}/bin/go
    - archive_format: tar
    - tar_options: z


golang-environment:
  file.managed:
    - name: /etc/profile.d/golang.sh
    - user: root
    - group: root
    - mode: 644
    - contents: |
        export PATH="$PATH:{{ go_path }}/bin"
        export GOPATH="$HOME/.go"


{#- iterate over the list of names we have for the go executables, create symlinks #}
{% for exec in go_executables %}
{{ exec }}-bin-symlink:
  file.symlink:
    - name: /usr/local/bin/{{ exec }}
    - target: {{ go_path }}/bin/{{ exec }}
{%- endfor %}

