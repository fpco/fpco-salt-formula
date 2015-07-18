# pillar looks like..
#
#     lvm:
#       data:
#         devices:
#           - xvdf
#         volumes:
#            home:
#              size: 200G
#              path: /home
#              type: ext3
#              mode: '755'
#              user: root
#              group: root
#       backup:
#         devices:
#           - xvdg
#         volumes:
#            backup:
#              size: 200G
#              path: /var/backups
#              type: ext3
#              mode: '750'
#              user: root
#              group: root

include:
  - storage.lvm.install

{%- set lvm_config = salt['pillar.get']('lvm', {}) %}

{%- for vol_group, config in lvm_config.items() %}


{%- for device in config['devices'] %}
pv-{{ device }}:
  lvm.pv_present:
    - name: /dev/{{ device }}
    - require_in:
        - lvm: vg-{{ vol_group }}
    - require:
        - module: lvm-deps
{%- endfor %}


vg-{{ vol_group }}:
  lvm.vg_present:
    - name: {{ vol_group }}
    {#- this next for-if combination results in lines like:
          devices: /dev/xvdf1
          devices: /dev/xvdf1,/dev/xvdg1 #}
    - devices: {% for dev in config['devices'] %}/dev/{{ dev }}{% if not loop.first %},{% endif %}{% endfor %}


{% for volume, cfg in config['volumes'].items() %}
lv-{{ volume }}:
  lvm.lv_present:
    - name: {{ volume }}
    - vgname: {{ vol_group }}
    - size: {{ cfg['size'] }}
    - require:
        - lvm: vg-{{ vol_group }}
  module.mod_watch:
    - name: extfs.mkfs
    - device: /dev/mapper/{{ vol_group }}-{{ volume }}
    - fs_type: ext3
    - watch:
        - lvm: lv-{{ volume }}
  file.directory:
    - name: {{ cfg['path'] }}
    - mode: {{ cfg['mode'] }}
    - user: {{ cfg['user'] }}
    - group: {{ cfg['group'] }}
    - makedirs: True
  mount.mounted:
    - name: {{ cfg['path'] }}
    - device: /dev/mapper/{{ vol_group }}-{{ volume }}
    - user: {{ cfg['user'] }}
    - fstype: {{ cfg['type'] }}
    - persist: True
    - require:
        - lvm:  lv-{{ volume }}
        - file: lv-{{ volume }}
        - module: lv-{{ volume }}
{%- endfor %}


{%- endfor %}
