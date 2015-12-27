# setup nomad service as an agent

{%- set home = '/var/lib/nomad' %}
{%- set conf_path = '/etc/nomad' %}
{%- set conf_file = conf_path ~ '/config.json' %}
{%- set server = salt['pillar.get']('nomad:server', False) %}
{%- set config_dir = '-config ' ~ conf_path ~ '/conf.d/' %}
{%- set default_args = 'agent ' ~ config_dir %}
{%- set service_ip = salt['grains.get']('ip4_interfaces')['eth0'][0] %}

{%- if server %}
  {%- set server_count = salt['pillar.get']('nomad:server_count', '3') %}
  {%- set bootstrap_args = ' -bootstrap-expect ' ~ server_count %}
  {%- set args = default_args ~ bootstrap_args %}
  {%- set desc = 'Nomad Server' %}
  {#- run nomad server as nomad user, nothing here requires root #}
  {%- set user = 'nomad' %}
{%- else %}
  {%- set args = default_args %}
  {%- set desc = 'Nomad Agent' %}
  {#- run nomad agent as root user, required for raw_exec driver #}
  {%- set user = 'root' %}
{%- endif %}

include:
  - nomad.config


nomad-upstart:
  file.managed:
    - name: /etc/init/nomad.conf
    - source: salt://nomad/files/upstart.conf
    - mode: 640
    - user: root
    - group: root
    - template: jinja
    - defaults: 
        description: {{ desc }}
        bin: /usr/local/bin/nomad
        args: {{ args }}
        run_as: {{ user }}
        home: {{ home }}
        config: {{ conf_file }}
  service.running:
    - name: nomad
    - enable: True
    - watch:
        - file: nomad-config
        - file: nomad-upstart

nomad-addr-system-env:
  file.append:
    - name: /etc/environment
    - text: NOMAD_ADDR="http://{{ service_ip }}:4646"
