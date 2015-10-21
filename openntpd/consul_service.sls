{%- set ip = salt['grains.get']('ip4_interfaces')['eth0'][0] %}

include:
  - consul.agent

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
                "script": "sudo service openntpd status",
                "interval": "30s"
              }
            ]
          }
        }
    - watch_in:
        - service: consul-upstart
