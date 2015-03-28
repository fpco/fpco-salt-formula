{%- set user = salt['pillar.get']('default_user', 'ubuntu') %}

drop-default-user:
  user.absent:
    - name: {{ user }}
