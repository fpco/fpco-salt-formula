# This is a run-once type of formula, intended to be run from a shell, not top.sls
#
# It will..
#
#   1) drop the script in place
#   2) run the script with the device specified in pillar (or default to xvdf)
#   3) remove the disk init script
#
#
# The formula accepts the following pillar..
# 
#     # the device name, to be appended to /dev/, default: xvdf
#     device: sda
#     # boolean flag to enable/disable lvm as the partition type, default: False
#     lvm: True
#
#
# It is expected this pillar would be provided on the cli, when applying the
# formula, eg:
# 
#     salt 'host' state.sls storage.fdisk pillar="{'device': 'xvdg', 'lvm': True}"


{%- set device = salt['pillar.get']('device', 'xvdf') %}
{%- set enable_lvm = salt['pillar.get']('lvm', False) %}
{%- set script_path = '/root/disk_init.sh' %}

disk-init-script:
  file.managed:
    - name: {{ script_path }}
    - user: root
    - group: root
    - mode: 750
    - contents: |
        #!/bin/sh
        # the disk device to initialize
        hdd="$1"
        
        printf "Initializing the device (${hdd}) with fdisk.."
        echo "n
        p
        1
        
        
        {% if enable_lvm -%}
        t
        8e
        {% endif -%}
        w
        "|fdisk $hdd
  cmd.run:
    - name: {{ script_path }} /dev/{{ device }}
    - user: root
    - require:
        - file: disk-init-script


remove-disk-init-script:
  file.absent:
    - name: {{ script_path }}
    - require:
        - cmd: disk-init-script


