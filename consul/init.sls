# install and setup consul
# download to master, from https://dl.bintray.com/mitchellh/consul/0.4.1_linux_amd64.zip
# unzip and drop into /srv/salt/consul/files/
# this has no assurance on the version installed.

{%- set home = '/home/consul' %}
{%- set user = 'consul' %}
{%- set bin_path = '/usr/local/bin/consul' %}
{%- set version = '0.5.2' %}
{%- set release_url = 'https://dl.bintray.com/mitchellh/consul/' + version + '_linux_amd64.zip' %}
{%- set checksum = '7bab204e9891d81a19422e70e20bbb527b7bb0b14c406f77ca38ca8dc11249fe5e45075e31a8eaed4bfce03f4af524b2603f4dcfe4c8b6ab0dfe367a5605553b' %}

include:
  - consul.python
  - consul.user
  - unzip


unpack-consul:
  archive.extracted:
    - name: {{ bin_path }}-{{ version }}
    - source: {{ release_url }}
    - source_hash: sha512={{ checksum }}
    - if_missing: {{ bin_path }}/consul
    - archive_format: zip
    - require:
        - pkg: unzip
  file.symlink:
    - name: {{ bin_path }}
    - target: {{ bin_path }}-{{ version }}/consul
    - require:
        - archive: unpack-consul


# .zip does not keep the execute bit.
# this also lets us block access to the exec,
# from users who are not in the consul group
consul-bin:
  file.managed:
    - name: {{ bin_path }}-{{ version }}/consul
    - user: root
    - group: {{ user }}
    - mode: 750


consul-conf-d:
  file.directory:
    - name: {{ home }}/conf.d
    - user: {{ user }}
    - group: {{ user }}
    - mode: 750
    - require:
        - user: consul-user
        - file: consul-user

