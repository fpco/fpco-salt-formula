{%- set ip = salt['grains.get']('ip4_interfaces')['eth0'][0] %}

include:
  - consul.reload

ntpd-consul-service:
  file.managed:
    - name: /home/consul/conf.d/ntpd_service.json
    - user: consul
    - group: consul
    - mode: 640
    - contents: |
        {
          "service": {
            "name": "ntpd",
            "tags": ["management"],
            "address": "{{ ip }}",
            "port": 123,
            "checks": [
              {
                "script": "pgrep -u ntpd ntpd",
                "interval": "30s"
              }
            ]
          }
        }
    # reload consul config after this service.json is in place
    - require_in:
        - cmd: consul-service-check-reload
