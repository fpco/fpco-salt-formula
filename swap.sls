{%- set size = salt['pillar.get']('size', 1) %}
{%- set file_path = '/var/' ~ size ~ 'GB.swap' %}

mkswap:
  file.managed:
    - name: /root/mkswap.sh
    - mode: 500
    - user: root
    - group: root
    - contents: |
        #!/bin/sh
        dd if=/dev/zero of={{ file_path }} bs=1M count={{ size * 1024 }}
        chmod 600 {{ file_path }}
        mkswap {{ file_path }}
        swapon {{ file_path }}
        echo "{{ file_path }} none swap sw 0 0" >> /etc/fstab
  cmd.run:
    - name: /root/mkswap.sh
    - require:
        - file: mkswap

mkswap-absent:
  file.absent:
    - name: /root/mkswap.sh
    - require:
        - cmd: mkswap
