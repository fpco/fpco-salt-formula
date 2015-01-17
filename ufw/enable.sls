# Enable ufw, expect that it is installed already
ufw-enable:
  cmd.run:
    - name: 'ufw enable'
    - unless: "ufw status | grep 'Status: active'"
