# default network interface
{%- set default_netif = 'eth0' %}
# use default net interface if the operator hasn't provided one
{%- set network_interface = salt['pillar.get']('vault:net_if', default_netif) %}
# lookup the first IP from the network interface specified
{%- set service_ip = salt['grains.get']('ip4_interfaces')[network_interface][0] %}

include:
  - consul.reload

vault-leader-check:
  file.managed:
    - name: /home/consul/conf.d/vault_server_check.json
    - user: consul
    - group: consul
    - mode: 640
    - contents: |
        {
          "check": {
            "name": "Hashistack Vault",
            "http": "http://{{ service_ip }}:8200/v1/sys/seal-status",
            "timeout": "10s",
            "interval": "30s"
          }
        }
    # reload consul config after this check.json is in place
    - require_in:
        - cmd: consul-service-check-reload
