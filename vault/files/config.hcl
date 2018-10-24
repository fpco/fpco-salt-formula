{%- set home = '/var/lib/vault' %}
{%- set ui = salt['pillar.get']('vault:ui', False) %}
{%- set default_file_backend = home ~ '/tmp' %}
{%- set default_netif = 'eth0' %}
{%- set network_interface = salt['pillar.get']('vault:net_if', default_netif) %}
{%- set default_ip = salt['grains.get']('ip4_interfaces')[network_interface][0] %}
{%- set dc = salt['pillar.get']('vault:datacenter', False) %}
{%- set http_port = salt['pillar.get']('vault:port', '8200') %}
{%- set http_ip = salt['pillar.get']('vault:ip', default_ip) %}
{%- set default_http_addr = 'http://' ~ http_ip ~ ':' ~ http_port %}
{%- set lease_ttl = salt['pillar.get']('vault:default_lease_ttl', False) %}
{%- set max_lease_ttl = salt['pillar.get']('vault:max_lease_ttl', False) %}
{%- set disable_mlock = salt['pillar.get']('vault:max_lease_ttl', False) %}
{%- set disable_tls = salt['pillar.get']('vault:disable_tls', 'false') %}
{%- set consul_backend = salt['pillar.get']('vault:consul:backend', True) %}
{%- set telemetry = salt['pillar.get']('vault:telemetry', False) %}

{#- if enabled, init pillar for consul as a backend #}
{%- if consul_backend %}
  {%- set default_consul_addr = default_ip ~ ':8500' %}
  {%- set consul_addr = salt['pillar.get']('vault:consul:address', default_consul_addr) %}
  {%- set consul_path = salt['pillar.get']('vault:consul:path', 'vault') %}
  {%- set consul_service_tags = salt['pillar.get']('vault:consul:service_tags', '') %}
  {%- set consul_scheme = salt['pillar.get']('vault:consul:scheme', 'https') %}
  {%- set consul_token = salt['pillar.get']('vault:consul:token', 'CONSUL_TOKEN_GOES_HERE') %}
  {%- if consul_scheme == 'https' %}
    {%- set tls_skip_verify = 'false' %}
  {%- else %}
    {%- set tls_skip_verify = 'true' %}
  {%- endif %}
{%- endif %}

{#- if enabled, configure vault to use consul as a backend #}
{%- if consul_backend %}
backend "consul" {
  address = "{{ consul_addr }}"
  path = "{{ consul_path }}"
  advertise_addr = "{{ default_http_addr }}"
  scheme = "{{ consul_scheme }}"
  service_tags = "{{ consul_service_tags }}"
  token = "{{ consul_token }}"
  {%- if dc %}"datacenter": "{{ dc }}",{%- endif %}
  tls_skip_verify = "{{ tls_skip_verify }}"
}
{#- else fall back to file backend #}
{%- else %}
backend "file" {
  path = "{{ default_file_backend }}"
{%- endif %}

{% if ui %}ui = true{% endif %}

{#- configure vault HTTP listener #}
listener "tcp" {
  address = "{{ http_ip }}:{{ http_port }}"
  tls_disable = "{{ disable_tls }}"
}

{#- configure vault stats interface #}
{%- if telemetry %}
telemetry {
  statsite_address = "127.0.0.1:8125"
  disable_hostname = true
}
{%- endif %}

{#- set default / max TTL lease #}
{%- if lease_ttl %}
default_lease_ttl = "{{ lease_ttl }}"
{% endif %}

{%- if max_lease_ttl %}
max_lease_ttl = "{{ max_lease_ttl }}"
{% endif %}

{#- disable mlock, if needed #}
{%- if disable_mlock %}
disable_mlock = "{{ disable_mlock }}"
{% endif %}
