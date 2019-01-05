# consul client on localhost
{%- set service_ip = '127.0.0.1' %}

include:
  - consul.reload

consul-client-check:
  file.managed:
    - name: /home/consul/conf.d/consul_client_check.json
    - user: consul
    - group: consul
    - mode: 640
    - contents: |
        {
          "check": {
            "name": "Consul Client Agent",
            "http": "http://{{ service_ip }}:8500/v1/status/leader",
            "timeout": "10s",
            "interval": "30s"
          }
        }
    # reload consul config after this check.json is in place
    - require_in:
        - cmd: consul-service-check-reload
