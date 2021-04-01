# setup and manage user (and home directory), for the nomad service

{%- set home = '/var/lib/nomad' %}
{%- set default_data_dir = home ~ '/tmp' %}
{%- set data_dir = salt['pillar.get']('nomad:data_dir', default_data_dir) %}
{%- set user = 'nomad' %}


nomad-user:
  user.present:
    - name: {{ user }}
    - system: True
    - usergroup: True
    - home: {{ home }}
    - shell: /bin/sh
    - groups:
        - docker
  file.directory:
    - name: {{ home }}
    - user: {{ user }}
    - group: {{ user }}
    - require:
        - file: nomad-data-dir

nomad-data-dir:
  file.directory:
    - name: {{ data_dir }}
    - user: {{ user }}
    - group: {{ user }}
    - mode: 750
    - makedirs: True
    - require:
        - user: nomad-user
