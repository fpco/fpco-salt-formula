# base policy: ensure ufw is enabled with a default deny policy on inbound traffic

include:
  - ufw


ufw-default_deny:
  cmd.run:
    - name: 'ufw default deny'
    # ensure we set default deny before the service state
    - require_in:
        - service: ufw
