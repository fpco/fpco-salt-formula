# setup and manage user (and home directory), for the nomad service

{%- set home = '/var/lib/nomad' %}
{%- set user = 'nomad' %}


nomad-user:
  user.present:
    - name: {{ user }}
    - system: True
    - gid_from_name: True
    - home: {{ home }}
    - shell: /bin/sh
    - groups:
        - docker
  file.directory:
    - name: {{ home }}
    - user: {{ user }}
    - group: {{ user }}
    - dir_mode: 750
    - file_mode: 640
    - recurse:
        - user
        - group
        - mode
    - require:
        - file: nomad-data-dir

nomad-data-dir:
  file.directory:
    - name: {{ home }}/tmp
    - user: {{ user }}
    - group: {{ user }}
    - mode: 750
    - makedirs: True
    - require:
        - user: nomad-user
