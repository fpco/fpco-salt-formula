mkswap:
  file.managed:
    - name: /root/mkswap.sh
    - mode: 500
    - user: root
    - group: root
    - contents: |
        #!/bin/sh
        dd if=/dev/zero of=/var/1GB.swap bs=1024 count=1048576
        chmod 600 /var/1GB.swap
        mkswap /var/1GB.swap
        swapon /var/1GB.swap
        echo "/var/1GB.swap none swap sw 0 0" >> /etc/fstab
  cmd.run:
    - name: /root/mkswap.sh
    - require:
        - file: mkswap

mkswap-absent:
  file.absent:
    - name: /root/mkswap.sh
    - require:
        - cmd: mkswap
