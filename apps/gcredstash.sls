{%- set version = 'v0.3.5' %}
{%- set executable = 'gcredstash-' ~ version ~ '-linux-amd64' %}
{%- set gzip_archive = executable ~ '.gz' %}
{%- set base_url = 'https://github.com/winebarrel/gcredstash/releases/download/' %}
{%- set archive_url = base_url ~ version ~ '/' ~ gzip_archive %}
{%- set checksum = 'e9b832763ea8dcd95f7a8b734cc576c22465d131eb1fa9b203cf8ee7fe1b6d2b829807e9b9e5ae7351ce60e46db1bab8eec94ff9fabcf56aba71ec120ff70239' %}

gcredstash-archive:
  file.managed:
    - name: /usr/local/bin/{{ gzip_archive }}
    - source: {{ archive_url }}
    - source_hash: sha512={{ checksum }}
    - unless: ls /usr/local/bin/{{ executable }}
  module.run:
    - name: archive.gunzip
    - gzipfile: /usr/local/bin/{{ gzip_archive }}
    - onchanges: [ { file: /usr/local/bin/{{ gzip_archive }} } ]
  cmd.run:
    - name: chmod +x /usr/local/bin/{{ executable }}
    - watch:
        - module: gcredstash-archive

gcredstash-bin:
  file.symlink:
    - name: /usr/local/bin/gcredstash
    - target: /usr/local/bin/{{ executable }}
    - require:
        - file: gcredstash-archive
  cmd.run:
    - name: gcredstash --version
    - require:
        - file: gcredstash-bin
        - cmd: gcredstash-archive
