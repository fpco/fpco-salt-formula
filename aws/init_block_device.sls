#
# If init with fdisk is disabled (default), this formula will:
#   1) ensure `/etc/fstab` has an entry for this device and mount point
#   2) mount the device where specified
#
# If init with fdisk is flagged, this formula will..
#   1) drop the script in place
#   2) run the script with either a default device/mount or with those details provided by pillar.
#   3) ensure `/etc/fstab` has an entry for this device and mount point
#   4) mount the device where specified
#   5) remove the disk init script
#
# the formula accepts the following pillar:
# 
#     disk:
#       # the device name, to be appended to /dev/, default: xvdf
#       device: sda
#       # the path to mount the device to, default: /mnt
#       mount: /custom/mnt
#       # boolean flag to enable/disable init with fdisk, default False
#       fdisk: True
#
#
# Via pillar files as you would normally..
#
# or provided on the cli, when applying the formula:
# 
#     salt 'host' state.sls aws.init_block_device  pillar="{'disk': {'device': 'xvdf', 'mount': '/var/data'}}"
#

{%- set device = salt['pillar.get']('disk:device', 'xvdf') %}
{%- set mount = salt['pillar.get']('disk:mount', '/mnt') %}
{%- set init_with_fdisk = salt['pillar.get']('disk:fdisk', False) %}
{%- set script_path = '/root/disk_init.sh' %}

{%- if init_with_fdisk %}
disk-init-script:
  file.managed:
    - name: {{ script_path }}
    - user: root
    - group: root
    - mode: 750
    - require_in:
        - file: mount-new-disk
    - contents: |
        #!/bin/sh
        # the disk device to initialize
        hdd="$1"
        # the filesystem mount point
        mnt="$2"
        
        printf "initialize the disk device specified {${hdd}}"
        echo "n
        p
        1
        
        
        w
        "|fdisk $hdd
        
        printf "create an EXT3 filesystem"
        mkfs.ext3 $hdd
        
        printf "ensure ${mnt} exists as a directory"
        mkdir -p $mnt
  cmd.run:
    - name: {{ script_path }} /dev/{{ device }} {{ mount }}
    - user: root
    - require:
        - file: disk-init-script
    - require_in:
        - cmd: mount-new-disk


remove-disk-init-script:
  file.absent:
    - name: {{ script_path }}
    - require:
        - cmd: disk-init-script
{%- endif %}

# we could include these bits in the script above
# but /etc/fstab deserves a stateful update..
mount-new-disk:
  file.append:
    - name: /etc/fstab
    - text: '/dev/{{ device }}    {{ mount }}    auto    defaults,nobootwait,comment=cloudconfig 0       2'
  cmd.run:
    - name: 'mount {{ mount }}'
    - require:
        - file: mount-new-disk

