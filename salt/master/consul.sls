{%- set ip = salt['grains.get']('ip4_interfaces')['eth0'][0] %}

include:
  - consul.reload

salt-master-consul-service:
  file.managed:
    - name: /home/consul/conf.d/salt_master_service.json
    - user: consul
    - group: consul
    - mode: 640
    - contents: |
        {
          "service": {
            "name": "salt-master",
            "tags": ["master"],
            "address": "{{ ip }}",
            "port": 4506,
            "checks": [
              {
                "script": "service salt-master status",
                "interval": "30s"
              }
            ]
          }
        }
    - watch_in:
        - service: consul-service-check-reload
