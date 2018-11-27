# setup vault service as an agent

{%- set home = '/var/lib/vault' %}
{%- set user = 'vault' %}
{%- set conf_path = '/etc/vault' %}
{%- set conf_file = conf_path ~ '/config.hcl' %}
{%- set config_args = ' -config ' ~ conf_file %}
{%- set default_args = 'server' ~ config_args %}
{%- set desc = 'Hashicorp Vault' %}
{%- set default_netif = 'eth0' %}
{%- set network_interface = salt['pillar.get']('vault:net_if', default_netif) %}
{%- set default_ip = salt['grains.get']('ip4_interfaces')[network_interface][0] %}
{%- set http_ip = salt['pillar.get']('vault:ip', default_ip) %}
{%- set http_port = salt['pillar.get']('vault:port', '8200') %}

{%- set service_config = '/etc/systemd/system/vault.service' %}
{%- set service_tpl = 'salt://systemd/files/basic.service.tpl' %}

include:
  - vault.user
  - vault.config


vault-service:
  file.managed:
    - name: {{ service_config }}
    - source: {{ service_tpl }}
    - mode: 640
    - user: root
    - group: root
    - template: jinja
    - defaults:
        description: {{ desc }}
        bin_path: /usr/local/bin/vault
        bin_opts: {{ default_args }}
        runas_user: {{ user }}
        runas_group: {{ user }}
        chdir: {{ home }}
        requires: network-online.target
  service.running:
    - name: vault
    - enable: True
    - watch:
        - file: vault-config
        - file: vault-service


vault-addr-system-env:
  file.append:
    - name: /etc/environment
    - text: VAULT_ADDR="http://{{ http_ip }}:{{ http_port }}"
