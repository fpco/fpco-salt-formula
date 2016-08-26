# this formula adds consul configs for the alertmanager service
{%- set default_port = '9093' %}
{%- set default_ip = salt['grains.get']('ip4_interfaces')['eth0'][0] %}
{%- set ip = salt['pillar.get']('alertmanager:ip', default_ip) %}
{%- set ip = salt['pillar.get']('alertmanager:port', default_port) %}

include:
  - consul.reload

alertmanager-consul-service:
  file.managed:
    - name: /home/consul/conf.d/alertmanager.json
    - user: consul
    - group: consul
    - mode: 640
    # consider using an HTTP-based service check in the future,
    # find a URL in alertmanager we can use..
    - contents: |
        {
          "service": {
            "name": "alertmanager",
            "address": "{{ ip }}",
            "port": {{ port }},
            "checks": [
              {
                "tcp": "{{ ip }}:{{ port }}",
                "interval": "30s"
              }
            ]
          },
          "watches": [
              {
                "type": "keyprefix",
                "prefix": "salt/roles/prometheus/alertmanager/",
                "handler": "sudo salt-call --local state.sls prometheus.alertmanager.config"
              }
          ]
        }
    - watch_in:
        - cmd: consul-service-check-reload

