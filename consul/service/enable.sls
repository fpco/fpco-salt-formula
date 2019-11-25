# setup consul service as an agent

{%- set os_release = salt['grains.get']('oscodename') %}
{%- set home = '/etc/consul' %}
{%- set user = 'consul' %}
{%- set default_args = 'agent -config-dir ' ~ home ~ '/conf.d/' %}
{%- set leader_count = salt['pillar.get']('consul:leader_count', False) %}
{%- set agent_ports = '8301' %}
{#- note, 8302 (WAN) is not yet included #}
{%- set leader_ports = '8300,8301,8400,8500,8600/tcp|8301,8600/udp' %}

{%- set auto_join_args = '' %}
{%- set auto_join_enabled = salt['pillar.get']('consul:auto_join:enabled', False) %}
{%- if  auto_join_enabled %}
  {%- set default_tag_key_name = 'consul_cluster' %}
  {%- set default_auto_join_provider = 'aws' %}
  {%- set auto_join_tag_key = salt['pillar.get']('consul:auto_join:tag_key', default_tag_key_name) %}
  {%- set auto_join_tag_val = salt['pillar.get']('consul:auto_join:tag_val', 'SET_CLUSTER_NAME') %}
  {%- set auto_join_provider = salt['pillar.get']('consul:auto_join:provider', default_auto_join_provider) %}
  {#- note the spaces here, they are important #}
  {%- set auto_join_prov = 'provider=' ~ auto_join_provider %}
  {%- set auto_join_tags = ' tag_key=' ~ auto_join_tag_key ~ ' tag_value=' ~ auto_join_tag_val %}
  {%- set auto_join_conf = ' "' ~ auto_join_prov ~ auto_join_tags ~ '"' %}
  {%- set auto_join_args = ' -retry-join' ~ auto_join_conf %}
{%- endif %}
 

{%- if leader_count %}
  {%- set bootstrap_args = ' -bootstrap-expect ' ~ leader_count %}
  {%- set args = default_args ~ auto_join_args ~ bootstrap_args %}
  {%- set desc = 'Consul Leader' %}
  {%- set ports = leader_ports %}
  {%- set default_netif = 'eth0' %}
  {%- set network_interface = salt['pillar.get']('consul:net_if', default_netif) %}
  {%- set http_ip = salt['grains.get']('ip4_interfaces')[network_interface][0] %}
  {%- set rpc_ip = '127.0.0.1' %}
{%- else %}
  {%- set args = default_args ~ auto_join_args %}
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
{%- set user = "root" %}
{%- set group = "consul" %}
{%- set conf_path = home ~ '/conf.d/00-config.hcl' %}
{%- set conf_src = 'salt://consul/files/config.hcl' %}
{%- set bin_path = '/usr/local/bin/consul' %}

{%- from "hashicorp/macro.sls" import render_app_config_formula with context %}
{%- from "hashicorp/macro.sls" import render_app_service_formula with context %}
{%- from "hashicorp/macro.sls" import render_app_ufw_formula with context %}

{{ render_app_config_formula(app, conf_path, conf_src, app, group) }}
{{ render_app_service_formula(app, desc, user, group, home, bin_path, args) }}
{{ render_app_ufw_formula(app, desc, ports) }}

