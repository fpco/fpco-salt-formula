include:
  - consul.reload

ntpd-consul-service:
  file.managed:
    - name: /home/consul/conf.d/ntpd_check.json
    - user: consul
    - group: consul
    - mode: 640
    - contents: |
        {
          "check": {
            "name": "Host ntpd",
            "args": ["sh", "pgrep", "-u", "ntpd", "ntpd"],
            "interval": "120s"
          }
        }
    # reload consul config after this service.json is in place
    - require_in:
        - cmd: consul-service-check-reload
