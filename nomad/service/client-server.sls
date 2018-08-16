# setup nomad service as an agent
# home directory for the user/service (runtime files)
{%- set home = salt['pillar.get']('nomad:server:home') %}
# configuration files go here
{%- set conf_path = salt['pillar.get']('nomad:config_root') %}
# primary config file
{%- set conf_file = salt['pillar.get']('nomad:server:config_file') %}
# cli option for nomad, path to config file
{%- set conf_opt_file = salt['pillar.get']('nomad:server:config_opt_file') %}
# cli option for nomad, directory for additional config files
{%- set conf_opt_dir = salt['pillar.get']('nomad:server:config_opt_dir') %}
# list of ports for UFW, for the agent
{%- set ufw_ports = salt['pillar.get']('nomad:server:ufw') %}
# should we enable/run the server?
{%- set server = salt['pillar.get']('nomad:server:enable') %}
# user/group to own files and run nomad as
{%- set user = salt['pillar.get']('nomad:server:user') %}
{%- set group = salt['pillar.get']('nomad:server:group') %}

# else is agent mode, no server, XXX we should make it possible to run both?
# cli option for running the nomad agent as a server/worker
{%- set args = salt['pillar.get']('nomad:server:args') %}
# description for the service unit file
{%- set desc = salt['pillar.get']('nomad:server:systemd_desc') %}
# path to the template/source rendered for the config file for nomad server service
{%- set conf_src = salt['pillar.get']('nomad:server:conf_src') %}
# name of the app, for the rendering macros below
{%- set app_name = salt['pillar.get']('nomad:server:systemd_name') %}
{%- set bin_path = '/usr/local/bin/nomad' %}

{%- from "hashicorp/macro.sls" import render_app_config_formula with context %}
{%- from "hashicorp/macro.sls" import render_app_service_formula with context %}
{%- from "hashicorp/macro.sls" import render_app_ufw_formula with context %}

{{ render_app_config_formula(app_name, conf_file, conf_src, user, group) }}
{{ render_app_service_formula(app_name, desc, user, group, home, bin_path, args) }}
{{ render_app_ufw_formula(app_name, desc, ufw_ports) }}


