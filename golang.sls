{%- set bin_path = '/usr/local' %}
{%- set version = '1.6.3' %}
{%- set go_root = bin_path ~ '/go' %}
{%- set release_url = 'https://storage.googleapis.com/golang/go' ~ version ~ '.linux-amd64.tar.gz' %}
{%- set checksum = '3f9766c242c76dc044ba963c4b5b0893885d0c958ff0945aeed893b0d12656fe6363c760a670ef7bf9ec1340156a8f403abc66c9f2cf352615ed521f5d7b027b' %}
{%- set go_executables = ['go', 'godoc', 'gofmt'] %}


golang-bin:
  archive.extracted:
    - name: {{ bin_path }}
    - source: {{ release_url }}
    - source_hash: sha512={{ checksum }}
    - if_missing: {{ go_root }}/bin/go
    - archive_format: tar
    - tar_options: z


golang-environment:
  file.managed:
    - name: /etc/profile.d/golang.sh
    - user: root
    - group: root
    - mode: 644
    - contents: |
        export GOPATH="$HOME/.go"
        export GOROOT="{{ go_root }}"
        export PATH="$PATH:$GOROOT/bin:$GOPATH/bin"


{#- iterate over the list of names we have for the go executables, create symlinks #}
{% for exec in go_executables %}
{{ exec }}-bin-symlink:
  file.symlink:
    - name: /usr/local/bin/{{ exec }}
    - target: {{ go_path }}/bin/{{ exec }}
{%- endfor %}

