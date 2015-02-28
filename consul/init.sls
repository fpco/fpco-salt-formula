# install and setup consul
# download to master, from https://dl.bintray.com/mitchellh/consul/0.4.1_linux_amd64.zip
# unzip and drop into /srv/salt/consul/files/
# this has no assurance on the version installed.

{%- set home = '/home/consul' %}
{%- set user = 'consul' %}
{%- set bin_path = '/usr/local/bin/consul' %}
{%- set version = '0.5.0' %}
{%- set release_url = 'https://dl.bintray.com/mitchellh/consul/' + version + '_linux_amd64.zip' %}
{%- set checksum = '581decd401b218c181b06a176c61cb35e6e4a6d91adf3837c5d2498c7aef98d6d4da536407c800e0d0d027914a174cdb04994e5bd5fdda7ee276b168fb4a5f8e' %}

include:
  - consul.user
  - unzip


consul-bin:
  archive.extracted:
    - name: {{ bin_path }}-{{ version }}
    - source: {{ release_url }}
    - source_hash: sha512={{ checksum }}
    - if_missing: {{ bin_path }}-{{ version }}/consul
    - archive_format: zip
    - require:
        - pkg: unzip
  file.symlink:
    - name: {{ bin_path }}
    - target: {{ bin_path }}-{{ version }}/consul
    - require:
        - archive: consul-bin


consul-conf-d:
  file.directory:
    - name: {{ home }}/conf.d
    - user: {{ user }}
    - group: {{ user }}
    - mode: 750
    - require:
        - user: consul-user
        - file: consul-user

