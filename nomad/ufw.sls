# configure ufw (firewall) policies for the nomad server and/or client

{%- from "hashicorp/macro.sls" import render_app_ufw_formula with context %}

{%- set server = salt['pillar.get']('nomad:server:enabled') %}
{%- set client = salt['pillar.get']('nomad:client:enabled') %}

# description for the service unit and ufw configuration files
{%- set desc = salt['pillar.get']('nomad:systemd_desc') %}
{%- set server_desc = desc ~ ' Server' %}
{%- set client_desc = desc ~ ' Client' %}
# name of the app, for the ufw rendering macro below
{%- set app_name = salt['pillar.get']('nomad:systemd_name') %}
{%- set server_name = app_name ~ '-server' %}
{%- set client_name = app_name ~ '-client' %}
# list of ports for UFW, for the server, client, and task allocations
{%- set server_ufw_ports = salt['pillar.get']('nomad:ufw:server') %}
{%- set client_ufw_ports = salt['pillar.get']('nomad:ufw:client') %}
# set ports based on `open_agent_ports` pillar, do we include those ports nomad
# will allocate to tasks dynamically (default), or do we keep it tight?
{%- if salt['pillar.get']('nomad:ufw:open_agent_ports') %}
  {%- set agent_task_ports = salt['pillar.get']('nomad:ufw:tasks') %}
  {%- set client_ufw_ports = client_ufw_ports ~ ',' ~ agent_task_ports %}
{%- endif %}

{%- if server %}
{{ render_app_ufw_formula(server_name, server_desc, server_ufw_ports) }}
{%- endif %}

{%- if client %}
{{ render_app_ufw_formula(client_name, client_desc, client_ufw_ports) }}
{%- endif %}
