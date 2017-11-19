# vim: sts=2 ts=2 sw=2 ft=jinja et ai
{%- set default_version = '0.3.2' %}
{%- set version = salt['pillar.get']('nomad:version', default_version) %}
{%- set PRE_0_4_0=['0.1.2','0.2.0','0.2.1','0.2.2','0.2.3','0.3.0','0.3.1','0.3.2'] %}
{%- set home = '/var/lib/nomad' %}
{%- set region = salt['pillar.get']('nomad:region', 'us') %}
{%- set dc = salt['pillar.get']('nomad:datacenter', 'dc') %}
{%- set syslog_facility = salt['pillar.get']('nomad:syslog_facility', 'LOCAL0') %}
{%- if salt['pillar.get']('nomad:enable_debug', False) %}{% set enable_debug = 'true' %}
{%- else %}{% set enable_debug = 'false' %}
{%- endif %}
{%- if salt['pillar.get']('nomad:enable_syslog', True) %}{% set enable_syslog = 'true' %}
{%- else %}{% set enable_syslog = 'false' %}
{%- endif %}
{%- set secret_key = salt['pillar.get']('nomad:secret_key', '') %}
{%- set log_level = salt['pillar.get']('nomad:log_level', 'INFO') %}
{%- set ext_ip = salt['grains.get']('ip4_interfaces')['eth0'][0] %}
{%- set bind_ip = salt['pillar.get']('nomad:bind_ip', ext_ip) %}
{%- set http_ip = salt['pillar.get']('nomad:http_ip', False) %}
{%- set rpc_ip = salt['pillar.get']('nomad:rpc_ip', False) %}
{%- set default_server = 'nomad-server.service.consul' %}

{#- server-specific #}
{%- set server = salt['pillar.get']('nomad:server', False) %}
{%- set num_schedulers = salt['pillar.get']('nomad:num_schedulers', False) %}
{%- set enabled_schedulers = salt['pillar.get']('nomad:enabled_schedulers', False) %}
{%- set bootstrap_expect = salt['pillar.get']('nomad:bootstrap_expect', 3) %}
{%- set retry_interval = salt['pillar.get']('nomad:retry_interval', '15s') %}
{%- set join_servers = salt['pillar.get']('nomad:servers', [default_server]) %}

{#- agent-specific #}
{#- the agent requires the port when referencing it in the config #}
{%- set default_agent_server = default_server ~ ':4647' %}
{%- set agent_servers = salt['pillar.get']('nomad:servers', [default_agent_server]) %}
{%- set default_node_id = salt['grains.get']('id') %}
{%- set node_id = salt['pillar.get']('nomad:node_id', default_node_id) %}
{%- set node_class = salt['pillar.get']('nomad:node_class', False) %}
{%- set meta = salt['pillar.get']('nomad:meta', {}) %}
{%- set opts = salt['pillar.get']('nomad:options', {}) %}
{%- set net_iface = salt['pillar.get']('nomad:network_interface', False) %}

{#- consul-specific #}
{%- set default_token = 'CONSUL_TOKEN_FOR_NOMAD' %}
{%- set consul_token = salt['pillar.get']('nomad:consul:token', default_token) %}
{%- set default_consul_port = '8500' %}
{%- set default_consul_host = 'localhost' %}
{%- set default_consul_addr = default_consul_host ~ ':' ~ default_consul_port %}
{%- set consul_addr = salt['pillar.get']('nomad:consul:addr', False) %}

{%- if server %}
  {#- use external/private IP when running server mode #}
  {%- set serf_ip = ext_ip %}
  {#- as a nomad server, assume the host is also a consul leader
      unless the operator has provided a consul addr via pillar  #}
  {%- if not consul_addr %}
    {%- set consul_addr = ext_ip ~ ':' ~ default_consul_port %}
  {%- endif %}
{#- we have a nomad client #}
{%- else %}
  {#- serf is server-only / not used by clients #}
  {%- set serf_ip = False %}
  {#- consul address not provided via pillar, use the default localhost:8500 #}
  {%- if not consul_addr %}
    {%- set consul_addr = default_consul_addr %}
  {%- endif %}
{%- endif %}

bind_addr = "{{ bind_ip }}"
addresses = {
    {% if serf_ip %}serf = "{{ serf_ip }}"{% endif %}
    {% if http_ip %}http = "{{ http_ip }}"{% endif %}
}
datacenter = "{{ dc }}"
data_dir = "{{ home }}/tmp/"
disable_anonymous_signature = true
disable_update_check = true
enable_debug = {{ enable_debug }}
enable_syslog = {{ enable_syslog }}
log_level = "{{ log_level }}"
name = "{{ node_id }}"
region = "{{ region }}"
syslog_facility = "{{ syslog_facility }}"

{%- if version not in PRE_0_4_0 %}
consul = {
  address = "{{ consul_addr }}"
  auto_advertise = true
  client_auto_join = true
  server_auto_join = true
  server_service_name = "nomad"
  client_service_name = "nomad-client"
  token = "{{ consul_token }}"
}
{%- endif %}

{%- if server %}
server = {
  enabled = true
  bootstrap_expect = {{ bootstrap_expect }}
    {%- if num_schedulers %}"num_schedulers = "{{ num_schedulers }}"{% endif %}
    {%- if enabled_schedulers %}"enabled_schedulers = "{{ enabled_schedulers }}"{% endif %}
  retry_join = [
      {% for s in join_servers %}"{{ s }}"
      {% endfor -%}
  ]
  retry_interval = "{{ retry_interval }}"
}
{%- else %}
client = {
  enabled = true
  options = {
    {%- if version in PRE_0_4_0 %}
    consul.address = "{{ consul_addr }}"
    consul.token = "{{ consul_token }}"
    {%- endif %}
    {%- for k,v in opts.items() %}
    {{ k }} = "{{ v }}"
    {% endfor %}
  }
  servers = [
      {% for s in agent_servers %}"{{ s }}"
      {%- endfor %}
  ]
  {% if meta %}meta = { {%- for k,v in meta.items() %}
    {{ k }} = "{{ v }}"
  {% endfor %}}
  {%- endif %}
  {% if net_iface %}"network_interface = "{{ net_iface }}"{% endif %}
  {% if node_class %}node_class = "{{ node_class }}"{% endif %}
}
{%- endif %}
