# allow port 22/ssh
ufw-allow_ssh:
  cmd.run:
    - name: 'ufw allow ssh'

