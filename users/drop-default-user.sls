{%- set user = salt['pillar.get']('default_user', 'ubuntu') %}
{%- set purge = True %}
{%- set force = False %}

drop-default-user:
  user.absent:
    - name: {{ user }}
    - purge: {{ purge }}
    - force: {{ force }}
  file.absent:
    - name: /etc/sudoers.d/90-cloud-init-users
