# setup and manage user (and home directory), for the consul service

{%- set home = '/home/consul' %}
{%- set user = 'consul' %}


consul-user:
  user.present:
    - name: {{ user }}
    - system: True
    - gid_from_name: True
    - home: {{ home }}
    - shell: /usr/sbin/nologin
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