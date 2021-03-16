# setup and manage user (and home directory), for the vault service

{%- set home = '/var/lib/vault' %}
{%- set user = 'vault' %}


vault-user:
  user.present:
    - name: {{ user }}
    - system: True
    - usergroup: True
    - home: {{ home }}
    - shell: /bin/sh
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
        - file: vault-data-dir

vault-data-dir:
  file.directory:
    - name: {{ home }}/tmp
    - user: {{ user }}
    - group: {{ user }}
    - mode: 750
    - makedirs: True
    - require:
        - user: vault-user
