# setup consul service as an agent

{%- set os_release = salt['grains.get']('oscodename') %}
{%- set home = '/home/consul' %}
{%- set user = 'consul' %}
{%- set default_args = 'agent -config-dir ' ~ home ~ '/conf.d/' %}
{%- set leader_count = salt['pillar.get']('consul:leader_count', False) %}
{%- set agent_ports = '8301' %}
{#- note, 8302 (WAN) is not yet included #}
{%- set leader_ports = '8300,8301,8400,8500,8600/tcp|8301,8600/udp' %}

{%- if leader_count %}
  {%- set bootstrap_args = ' -bootstrap-expect ' ~ leader_count %}
  {%- set args = default_args ~ bootstrap_args %}
  {%- set desc = 'Consul Leader' %}
  {%- set ports = leader_ports %}
  {%- set default_netif = 'eth0' %}
  {%- set network_interface = salt['pillar.get']('consul:net_if', default_netif) %}
  {%- set http_ip = salt['grains.get']('ip4_interfaces')[network_interface][0] %}
  {%- set rpc_ip = '127.0.0.1' %}
{%- else %}
  {%- set args = default_args %}
  {%- set desc = 'Consul Agent' %}
  {%- set ports = agent_ports %}
  {%- set http_ip = '127.0.0.1' %}
  {%- set rpc_ip = '127.0.0.1' %}
{%- endif %}

{%- if os_release == 'trusty' %}
  {%- set service_config = '/etc/init/consul.conf' %}
  {%- set service_tpl = 'salt://upstart/files/generic.conf' %}
{%- else %}
  {%- set service_config = '/etc/systemd/system/consul.service' %}
  {%- set service_tpl = 'salt://systemd/files/basic.service.tpl' %}
{%- endif %}


consul-addr-system-env:
  file.append:
    - name: /etc/environment
    - text: |
        CONSUL_HTTP_ADDR="{{ http_ip }}:8500"
        CONSUL_RPC_ADDR="{{ rpc_ip }}:8400"


{%- set app = "consul" %}
{%- set group = "root" %}
{%- set conf_path = '/home/consul/conf.d/00-config.json' %}
{%- set conf_src = 'salt://consul/files/config.json' %}

{%- from "hashicorp/macro.sls" import render_app_config_formula with context %}
{%- from "hashicorp/macro.sls" import render_app_service_formula with context %}
{%- from "hashicorp/macro.sls" import render_app_ufw_formula with context %}

{{ render_app_config_formula(app, conf_path, conf_src, app, group) }}
{{ render_app_service_formula(app, desc, user, group, home, args) }}
{{ render_app_ufw_formula(app, desc, ports) }}

