{%- set user = salt['pillar.get']('default_user', 'ubuntu') %}

drop-default-user:
  user.absent:
    - name: {{ user }}
  file.absent:
    - name: /etc/sudoers.d/90-cloud-init-users
