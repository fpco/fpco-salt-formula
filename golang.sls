{%- set bin_path = '/usr/local' %}
{%- set version = '1.7.1' %}
{%- set go_root = bin_path ~ '/go' %}
{%- set release_url = 'https://storage.googleapis.com/golang/go' ~ version ~ '.linux-amd64.tar.gz' %}
{%- set checksum = '225aa1d5481e5fc6d7a75bd1ded26d48a2398dafa6d5fe8e37141a3f22a8177daf32615c1df65495d62796d740889eca4795fcd1423a9dbd55bd00081c6cb1e0' %}
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

