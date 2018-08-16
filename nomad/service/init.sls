# setup nomad service as an agent
# home directory for the user/service (runtime files)
{%- set home = '/var/lib/nomad' %}
# configuration files go here
{%- set conf_path = '/etc/nomad' %}
# primary config file
{%- set conf_file = conf_path ~ '/config' %}
# cli option for nomad, path to config file
{%- set conf_opt_file = '-config ' ~ conf_file %}
# cli option for nomad, directory for additional config files
{%- set conf_opt_dir = '-config ' ~ conf_path ~ '/conf.d/' %}
# default cli args, always included
{%- set default_args = conf_opt_file ~ ' ' ~ conf_opt_dir %}
# default network interface
{%- set default_netif = 'eth0' %}
# use default net interface if the operator hasn't provided one
{%- set network_interface = salt['pillar.get']('nomad:net_if', default_netif) %}
# lookup the first IP from the network interface specified
{%- set service_ip = salt['grains.get']('ip4_interfaces')[network_interface][0] %}
# list of ports for UFW, for the agent
{%- set agent_ports = '4646' %}
# list of ports for UFW, for the server, tcp/udp
{%- set server_ports = '4646,4647,4648/tcp|4648/udp' %}
# should we enable/run the server?
{%- set server = salt['pillar.get']('nomad:server', False) %}
# group to own files and run nomad as
{%- set group = salt['pillar.get']('nomad:group', 'nomad') %}

# when in server mode, we need to set a few more variables
{%- if server %}
  # the number of servers to expect for bootstrap election
  {%- set server_count = salt['pillar.get']('nomad:server_count', '3') %}
  # cli option for -bootstrap-expect
  {%- set bootstrap_args = ' -bootstrap-expect ' ~ server_count %}
  # cli option for running the nomad agent as a server
  {%- set args = 'agent -server ' ~ default_args ~ bootstrap_args %}
  # description for the service unit file
  {%- set desc = 'Nomad Server' %}
  # list of ports for the server
  {%- set ports = server_ports %}
  {#- run nomad server as nomad user, nothing here requires root #}
  {%- set user = salt['pillar.get']('nomad:user', 'nomad') %}
# else is agent mode, no server, XXX we should make it possible to run both?
{%- else %}
  # cli option for running the nomad agent as a client/worker
  {%- set args = 'agent -client ' ~ default_args %}
  # description for the service unit file
  {%- set desc = 'Nomad Agent' %}
  # set ports based on `open_agent_ports` pillar, do we include those ports nomad
  # will allocate to tasks dynamically (default), or do we keep it tight?
  {%- if salt['pillar.get']('nomad:open_agent_ports', True) %}
    {%- set ports = agent_ports + ',20000:60000/tcp|20000:60000/udp' %}
  {%- else %}
    {%- set ports = agent_ports %}
  {%- endif %}
  {#- run nomad agent as root user by default, required for raw_exec driver #}
  {%- set user = salt['pillar.get']('nomad:user', 'root') %}
{%- endif %}

{%- set conf_path = '/etc/nomad' %}

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


{%- set app = "nomad" %}
{%- set conf_path = '/etc/nomad/config' %}
{%- set conf_src = 'salt://nomad/files/config.hcl' %}
{%- set bin_path = '/usr/local/bin/nomad' %}

{%- from "hashicorp/macro.sls" import render_app_config_formula with context %}
{%- from "hashicorp/macro.sls" import render_app_service_formula with context %}
{%- from "hashicorp/macro.sls" import render_app_ufw_formula with context %}

{{ render_app_config_formula(app, conf_path, conf_src, app, group) }}
{{ render_app_service_formula(app, desc, user, group, home, bin_path, args) }}
{{ render_app_ufw_formula(app, desc, ports) }}


