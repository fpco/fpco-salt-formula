include:
  - ufw

# allow port 22/ssh
ufw-allow_ssh:
  cmd.run:
    - name: 'ufw allow ssh'
    - unless: 'ufw status| grep "^22  " | grep ALLOW'
    - require_in:
        - service: ufw
