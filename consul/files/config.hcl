{%- set home = '/home/consul' %}
{%- set webui = salt['pillar.get']('consul:webui', False) %}
{%- set leaders = salt['pillar.get']('consul:leaders', []) %}
{%- set default_dc = 'dc1' %}
{%- set dc = salt['pillar.get']('consul:datacenter', default_dc) %}
{%- set client_token = salt['pillar.get']('consul:client_token', False) %}
{%- set secret_key = salt['pillar.get']('consul:secret_key', '') %}
{%- set log_level = salt['pillar.get']('consul:log_level', 'INFO') %}
{%- set master_token = salt['pillar.get']('consul:master_token', '') %}
{%- set acl_default_policy = salt['pillar.get']('consul:acl_default_policy', False) %}
{%- set disable_remote_exec = salt['pillar.get']('consul:disable_remote_exec', True) %}
{%- set enable_script_checks = salt['pillar.get']('consul:enable_script_checks', True) %}
{%- set leader_count = salt['pillar.get']('consul:leader_count', False) %}
{%- set default_netif = 'eth0' %}
{%- set network_interface = salt['pillar.get']('consul:net_if', default_netif) %}
{%- set ext_ip = salt['grains.get']('ip4_interfaces')[network_interface][0] %}
{%- set retry_interval = salt['pillar.get']('consul:retry_interval', '15s') %}
{%- set default_domain = 'consul.' %}
{%- set domain = salt['pillar.get']('consul:domain', default_domain) %}

{%- if leader_count %}
  {#- JSON does not want to see True/False #}
  {%- set server = 'true' %}
  {#- use external/private IP when running server mode #}
  {%- set http_ip = ext_ip %}
{%- else %}
  {%- set server = 'false' %}
  {%- set http_ip = '127.0.0.1' %}
{%- endif -%}

{%- if server %}
addresses = {
  http = "{{ http_ip }}"
}
acl_datacenter = "{{ dc }}"
acl_master_token = "{{ master_token }}"
domain = "{{ domain }}"
{%- endif %}

acl_agent_token = "{{ client_token }}"

{% if acl_default_policy %}acl_default_policy = "{{ acl_default_policy }}"{%- endif %}

bind_addr = "{{ ext_ip }}"
datacenter = "{{ dc }}"
data_dir = "{{ home }}/tmp/"
disable_update_check = true
disable_remote_exec = {% if disable_remote_exec %}true{% else %}false{% endif %}
enable_script_checks = {% if enable_script_checks %}true{% else %}false{% endif %}
enable_syslog = true
encrypt = "{{ secret_key }}"
log_level = "{{ log_level }}"
node_name = "{{ salt['grains.get']('id') }}"
server = {{ server }}

{% if leaders %}
retry_join = [
  {% for leader in leaders %}"{{ leader }}"{%- if not loop.last %}
  {% endif %}
  {% endfor -%}
]
retry_interval = "{{ retry_interval }}"
{%- endif %}

{% if webui %}ui = true{% endif %}
watches = []
