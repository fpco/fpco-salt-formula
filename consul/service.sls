# setup consul service as an agent

{%- set home = '/home/consul' %}
{%- set user = 'consul' %}
{%- set webui = salt['pillar.get']('consul:webui', False) %}
{%- set default_args = 'agent -config-dir ' ~ home ~ '/conf.d/' %}
{%- set leader_count = salt['pillar.get']('consul:leader_count', False) %}

{%- if leader_count %}
  {%- set bootstrap_args = ' -bootstrap-expect ' ~ leader_count %}
  {%- set args = default_args ~ bootstrap_args %}
  {%- set desc = 'Consul Leader' %}
  {%- set http_ip = salt['grains.get']('ip4_interfaces')['eth0'][0] %}
  {%- set rpc_ip = '127.0.0.1' %}
{%- else %}
  {%- set args = default_args %}
  {%- set desc = 'Consul Agent' %}
  {%- set http_ip = '127.0.0.1' %}
  {%- set rpc_ip = '127.0.0.1' %}
{%- endif %}

include:
  - consul.config

consul-upstart:
  file.managed:
    - name: /etc/init/consul.conf
    - source: salt://consul/files/upstart.conf
    - mode: 640
    - user: root
    - group: root
    - template: jinja
    - defaults: 
        description: {{ desc }}
        bin_path: /usr/local/bin/consul
        cmd_args: {{ args }}
        run_as: {{ user }}
        home: {{ home }}
        webui: {{ webui }}
  service.running:
    - name: consul
    - enable: True
    - watch:
        - file: consul-bin
        - file: consul-user
        - file: consul-config
        - file: consul-upstart


consul-addr-system-env:
  file.append:
    - name: /etc/environment
    - text: |
        CONSUL_HTTP_ADDR="{{ http_ip }}:8500"
        CONSUL_RPC_ADDR="{{ rpc_ip }}:8400"
