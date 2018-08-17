# setup nomad service as an agent
# home directory for the user/service (runtime files)
{%- set home = salt['pillar.get']('nomad:home') %}
# configuration files go here
{%- set conf_path = salt['pillar.get']('nomad:config_root') %}
# primary config file
{%- set conf_file = salt['pillar.get']('nomad:config_file') %}
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
