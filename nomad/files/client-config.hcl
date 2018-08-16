# vim: sts=2 ts=2 sw=2 ft=jinja et ai
{%- set home = salt['pillar.get']('nomad:client:home') %}
{%- set region = salt['pillar.get']('nomad:region', 'us') %}
{%- set dc = salt['pillar.get']('nomad:datacenter', 'dc1') %}
{%- set syslog_facility = salt['pillar.get']('nomad:syslog_facility', 'LOCAL0') %}
{%- if salt['pillar.get']('nomad:enable_debug', False) %}{% set enable_debug = 'true' %}
{%- else %}{% set enable_debug = 'false' %}
{%- endif %}
{%- if salt['pillar.get']('nomad:enable_syslog', True) %}{% set enable_syslog = 'true' %}
{%- else %}{% set enable_syslog = 'false' %}
{%- endif %}
{%- set secret_key = salt['pillar.get']('nomad:secret_key', '') %}
{%- set log_level = salt['pillar.get']('nomad:log_level', 'INFO') %}
{%- set default_netif = 'eth0' %}
{%- set network_interface = salt['pillar.get']('network_interface', default_netif) %}
{%- set ext_ip = salt['grains.get']('ip4_interfaces')[network_interface][0] %}
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

{#- serf is server-only / not used by clients #}
{%- set serf_ip = False %}
{#- consul address not provided via pillar, use the default localhost:8500 #}
{%- if not consul_addr %}
  {%- set consul_addr = default_consul_addr %}
{%- endif %}

bind_addr = "{{ bind_ip }}"
addresses {
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

consul {
  address = "{{ consul_addr }}"
  auto_advertise = true
  client_auto_join = true
  server_auto_join = true
  server_service_name = "nomad"
  client_service_name = "nomad-client"
  token = "{{ consul_token }}"
}

client {
  enabled = true
  options {
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
