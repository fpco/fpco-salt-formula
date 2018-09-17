# configure ufw (firewall) policies for the vault server

{%- from "hashicorp/macro.sls" import render_app_ufw_formula with context %}

# description for the service unit and ufw configuration files
{%- set desc = salt['pillar.get']('vault:systemd_desc', "Hashiscorp Vault Server") %}
{%- set server_name = "vault" %}
# list of ports for UFW, for the server and task allocations
{%- set server_ufw_ports = salt['pillar.get']('vault:port',"8200") %}

{{ render_app_ufw_formula(server_name, server_desc, server_ufw_ports) }}
