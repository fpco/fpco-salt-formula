# setup consul service as an agent

{%- set os_release = salt['grains.get']('oscodename') %}
{%- set home = '/home/consul' %}
{%- set user = 'consul' %}
{%- set webui = salt['pillar.get']('consul:webui', False) %}
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
  {%- set http_ip = salt['grains.get']('ip4_interfaces')['eth0'][0] %}
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

include:
  - consul.config

consul-service:
  file.managed:
    - name: {{ service_config }}
    - source: {{ service_tpl }}
    - mode: 640
    - user: root
    - group: root
    - template: jinja
    - defaults: 
        description: {{ desc }}
        bin_path: /usr/local/bin/consul
        args: {{ args }}
        runas_user: {{ user }}
        runas_group: {{ user }}
        chdir: {{ home }}
  service.running:
    - name: consul
    - enable: True
    - watch:
        - file: consul-user
        - file: consul-config
        - file: consul-service


consul-addr-system-env:
  file.append:
    - name: /etc/environment
    - text: |
        CONSUL_HTTP_ADDR="{{ http_ip }}:8500"
        CONSUL_RPC_ADDR="{{ rpc_ip }}:8400"


consul-ufw-app-config:
  file.managed:
    - name: /etc/ufw/applications.d/consul.ufw
    - source: salt://ufw/files/etc/ufw/applications.d/app_config.jinja
    - user: root
    - group: root
    - mode: 0640
    - context:
        app: consul
        title: consul
        description: {{ desc }}
        ports: {{ ports }}
    - template: jinja
  cmd.run:
    - name: 'ufw allow consul'
    - watch:
        - file: consul-ufw-app-config
