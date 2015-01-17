# base policy: ensure ufw is enabled with a default deny policy on inbound traffic
ufw-default_deny:
  cmd.run:
    - name: 'ufw default deny'

