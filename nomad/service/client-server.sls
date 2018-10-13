# setup nomad service as an agent
# home directory for the user/service (runtime files)
{%- set home = salt['pillar.get']('nomad:home') %}
# configuration files go here
{%- set conf_path = salt['pillar.get']('nomad:config_root') %}
# primary config file
{%- set conf_file = salt['pillar.get']('nomad:config_file') %}
# config file for vault
{%- set vault_config_file = salt['pillar.get']('nomad:vault_config_file') %}
# cli option for nomad, path to config file
{%- set conf_opt_file = salt['pillar.get']('nomad:config_opt_file') %}
# cli option for nomad, directory for additional config files
{%- set conf_opt_dir = salt['pillar.get']('nomad:config_opt_dir') %}
# user/group to run nomad as
{%- set run_user = salt['pillar.get']('nomad:run_as_user') %}
# user/group to own files as
{%- set user = salt['pillar.get']('nomad:user') %}
{%- set group = salt['pillar.get']('nomad:group') %}

# path to the template/source rendered for the config file for nomad server service
{%- set conf_src = 'salt://nomad/files/client-server-config.hcl' %}
# cli options passed to nomad executable in the systemd unit file
{%- set args = salt['pillar.get']('nomad:systemd_bin_args') %}
# description for the service unit and ufw configuration files
{%- set desc = salt['pillar.get']('nomad:systemd_desc') %}
# name of the app, for config, systemd and ufw rendering macros
{%- set app_name = salt['pillar.get']('nomad:systemd_name') %}
{%- set bin_path = '/usr/local/bin/nomad' %}

{%- from "hashicorp/macro.sls" import render_app_config_formula with context %}
{%- from "hashicorp/macro.sls" import render_app_service_formula with context %}

{{ render_app_config_formula(app_name, conf_file, conf_src, user, group) }}
{{ render_app_service_formula(app_name, desc, run_user, group, home, bin_path, args) }}


# default network interface
{%- set default_netif = 'eth0' %}
# use default net interface if the operator hasn't provided one
{%- set network_interface = salt['pillar.get']('nomad:net_if', default_netif) %}
# lookup the first IP from the network interface specified
{%- set service_ip = salt['grains.get']('ip4_interfaces')[network_interface][0] %}
#

{%- set tls = salt['pillar.get']('nomad:tls', {}) %}
{%- if tls %}
  {%- set ca_cert_path = tls['ca_file'] %}
  {%- set client_cert_path = tls['cert_file'] %}
  {%- set client_key_path = tls['key_file'] %}
{%- endif %}


nomad-addr-system-env:
  file.append:
    - name: /etc/environment
    - text: |
        NOMAD_ADDR="http://{{ service_ip }}:4646"
        {%- if tls %}
        NOMAD_CACERT="{{ ca_cert_path }}:"
        NOMAD_CLIENT_CERT="{{ client_cert_path }}:"
        NOMAD_CLIENT_KEY="{{ client_key_path }}:"
        {%- endif %}

nomad-vault-config:
  file.managed:
    - name: {{ vault_config_file }}
    - source: salt://nomad/files/vault.hcl
    - user: {{ user }}
    - group: {{ group }}
    - mode: 640
    - template: jinja
    - watch_in:
      - service: nomad-service

