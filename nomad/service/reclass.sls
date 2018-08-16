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
# list of ports for UFW, for the agent
{%- set agent_ports = salt['pillar.get']('nomad:ufw:agent_ports') %}
# list of ports for UFW, for the server, tcp/udp
{%- set server_ports = salt['pillar.get']('nomad:ufw:server_ports') %}
# should we enable/run the server?
{%- set server = salt['pillar.get']('nomad:server') %}
# user/group to own files and run nomad as
{%- set user = salt['pillar.get']('nomad:user') %}
{%- set group = salt['pillar.get']('nomad:group') %}

# when in server mode, we need to set a few more variables
{%- if server %}
  # the number of servers to expect for bootstrap election
  {%- set server_count = salt['pillar.get']('nomad:server_count') %}
  # cli option for -bootstrap-expect
  {%- set bootstrap_args = salt['pillar.get']('nomad:bootstrap_args') %}
  # cli option for running the nomad agent as a server
  {%- set args = salt['pillar.get']('nomad:server_args') %}
  # description for the service unit file
  {%- set desc = salt['pillar.get']('nomad:server_systemd_desc') %}
  # list of ports for the server
  {%- set ports = server_ports %}
  {#- run nomad server as nomad user, nothing here requires root #}
  {%- set user = salt['pillar.get']('nomad:user') %}
# else is agent mode, no server, XXX we should make it possible to run both?
{%- else %}
  # cli option for running the nomad agent as a client/worker
  {%- set args = salt['pillar.get']('nomad:client_args') %}
  # description for the service unit file
  {%- set desc = salt['pillar.get']('nomad:client_systemd_desc') %}
  # set ports based on `open_agent_ports` pillar, do we include those ports nomad
  # will allocate to tasks dynamically (default), or do we keep it tight?
  {%- if salt['pillar.get']('nomad:open_agent_ports') %}
    {%- set agent_task_ports = salt['pillar.get']('nomad:agent_task_ports') %}
    {%- set ports = agent_ports ~ ' ' ~ agent_task_ports %}
  {%- else %}
    {%- set ports = agent_ports %}
  {%- endif %}
  {#- run nomad agent as root user by default, required for raw_exec driver #}
  {%- set user = salt['pillar.get']('nomad:user', 'root') %}
{%- endif %}

{%- set app = "nomad" %}
{%- set conf_src = 'salt://nomad/files/config.hcl' %}
{%- set bin_path = '/usr/local/bin/nomad' %}

{%- from "hashicorp/macro.sls" import render_app_config_formula with context %}
{%- from "hashicorp/macro.sls" import render_app_service_formula with context %}
{%- from "hashicorp/macro.sls" import render_app_ufw_formula with context %}

{{ render_app_config_formula(app, conf_file, conf_src, app, group) }}
{{ render_app_service_formula(app, desc, user, group, home, bin_path, args) }}
{{ render_app_ufw_formula(app, desc, ports) }}


