# setup nomad service as an agent
{%- set home = '/var/lib/nomad' %}
{%- set conf_path = '/etc/nomad' %}
{%- set conf_file = conf_path ~ '/config' %}
{%- set conf_opt_file = '-config ' ~ conf_file %}
{%- set conf_opt_dir = '-config ' ~ conf_path ~ '/conf.d/' %}
{%- set default_args = conf_opt_file ~ ' ' ~ conf_opt_dir %}
{%- set default_netif = 'eth0' %}
{%- set network_interface = salt['pillar.get']('nomad:net_if', default_netif) %}
{%- set service_ip = salt['grains.get']('ip4_interfaces')[network_interface][0] %}
{%- set agent_ports = '4646' %}
{%- set server_ports = '4646,4647,4648/tcp|4648/udp' %}
{%- set server = salt['pillar.get']('nomad:server', False) %}
{%- set group = salt['pillar.get']('nomad:group', 'nomad') %}

{%- if server %}
  {%- set server_count = salt['pillar.get']('nomad:server_count', '3') %}
  {%- set bootstrap_args = ' -bootstrap-expect ' ~ server_count %}
  {%- set args = 'agent -server ' ~ default_args ~ bootstrap_args %}
  {%- set desc = 'Nomad Server' %}
  {%- set ports = server_ports %}
  {#- run nomad server as nomad user, nothing here requires root #}
  {%- set user = salt['pillar.get']('nomad:user', 'nomad') %}
{%- else %}
  {%- set args = 'agent -client ' ~ default_args %}
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

{%- from "hashicorp/macro.sls" import render_app_config_formula with context %}
{%- from "hashicorp/macro.sls" import render_app_service_formula with context %}
{%- from "hashicorp/macro.sls" import render_app_ufw_formula with context %}

{{ render_app_config_formula(app, conf_path, conf_src, app, group) }}
{{ render_app_service_formula(app, desc, user, group, home, args) }}
{{ render_app_ufw_formula(app, desc, ports) }}


