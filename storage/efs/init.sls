# stateful translation of the folllowing..
#   apt-get install nfs-common
#   mkdir /efs
#   mount -t nfs4 $(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone).fs-051df3ac.efs.us-west-2.amazonaws.com:/ /efs
#
# ..but for as many mount points as you would like, efs_mounts pillar looks like:
#
#    efs_mounts:
#      efs:
#        path: /efs
#        efs_id: fs-051df3ac
#        region: us-west-2
#        mode: 755
#        user: root
#        group: root
#      data:
#        path: /data
#        efs_id: fs-93da23bc
#        region: us-west-2
#        mode: 750
#        user: root
#        group: datasci
#
{%- set query_url = 'http://169.254.169.254' %}
{%- set az_uri = '/latest/meta-data/placement/availability-zone' %}
{%- set az = salt['cmd.run']('curl -s ' + query_url + az_uri ) %}
{%- set efs_mounts = salt['pillar.get']('efs_mounts', {}) %}


nfs:
  pkg.latest:
    - name: nfs-common

{%- if efs_mounts %}
{%- for name, m in efs_mounts.items() %}
efs-mount-{{ name }}:
  file.directory:
    - name: {{ m['path'] }}
    - user: {{ m['user'] }}
    - group: {{ m['group'] }}
    - dir_mode: {{ m['mode'] }}
    - makedirs: True
  mount.mounted:
    - name: {{ m['path'] }}
    - device: {{ az }}.{{ m['efs_id'] }}.efs.{{ m['region'] }}.amazonaws.com:/
    - user: {{ m['user'] }}
    - fstype: nfs4
    - persist: True
    - require:
        - pkg:  nfs
        - file:  efs-mount-{{ name }}

{%- endfor %}
{%- endif %}
