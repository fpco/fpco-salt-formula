# default network interface
{%- set default_netif = 'eth0' %}
# use default net interface if the operator hasn't provided one
{%- set network_interface = salt['pillar.get']('nomad:net_if', default_netif) %}
# lookup the first IP from the network interface specified
{%- set service_ip = salt['grains.get']('ip4_interfaces')[network_interface][0] %}

include:
  - consul.reload

nomad-client-check:
  file.managed:
    - name: /home/consul/conf.d/nomad_client_check.json
    - user: consul
    - group: consul
    - mode: 640
    - contents: |
        {
          "check": {
            "name": "Nomad Client Agent",
            "http": "http://{{ service_ip }}:4646/v1/status/leader",
            "timeout": "10s",
            "interval": "30s"
          }
        }
    # reload consul config after this check.json is in place
    - require_in:
        - cmd: consul-service-check-reload
