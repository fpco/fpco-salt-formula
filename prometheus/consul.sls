# this formula adds consul configs for the prometheus service
{%- set ip = salt['grains.get']('ip4_interfaces')['eth0'][0] %}

include:
  - consul.reload

prometheus-consul-service:
  file.managed:
    - name: /home/consul/conf.d/prometheus.json
    - user: consul
    - group: consul
    - mode: 640
    # consider using an HTTP-based service check in the future,
    # find a URL in prometheus we can use..
    - contents: |
        {
          "service": {
            "name": "prometheus",
            "address": "{{ ip }}",
            "port": 9090,
            "checks": [
              {
                "script": "service prometheus status",
                "interval": "30s"
              }
            ]
          },
          "watches": [
              {
                "type": "keyprefix",
                "prefix": "salt/roles/prometheus/prometheus/",
                "handler": "sudo salt-call --local state.sls prometheus.service"
              }
          ]
        }
    - watch_in:
        - cmd: consul-service-check-reload

