# setup nomad service as an agent

{%- set home = '/var/lib/nomad' %}
{%- set conf_path = '/etc/nomad' %}
{%- set conf_file = conf_path ~ '/config.json' %}
{%- set conf_opt_file = '-config ' ~ conf_file %}
{%- set conf_opt_dir = '-config ' ~ conf_path ~ '/conf.d/' %}
{%- set default_args = conf_opt_file ~ ' ' ~ conf_opt_dir %}
{%- set service_ip = salt['grains.get']('ip4_interfaces')['eth0'][0] %}
{%- set agent_ports = '4646' %}
{%- set server_ports = '4646,4647,4648/tcp|4648/udp' %}
{%- set server = salt['pillar.get']('nomad:server', False) %}

{%- if server %}
  {%- set server_count = salt['pillar.get']('nomad:server_count', '3') %}
  {%- set bootstrap_args = ' -bootstrap-expect ' ~ server_count %}
  {%- set args = 'agent -server ' ~ default_args ~ bootstrap_args %}
  {%- set desc = 'Nomad Server' %}
  {%- set ports = server_ports %}
  {#- run nomad server as nomad user, nothing here requires root #}
  {%- set user = 'nomad' %}
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


nomad-ufw-app-config:
  file.managed:
    - name: /etc/ufw/applications.d/nomad.ufw
    - source: salt://ufw/files/etc/ufw/applications.d/app_config.jinja
    - user: root
    - group: root
    - mode: 0640
    - context:
        app: nomad
        title: nomad
        description: {{ desc }}
        ports: {{ ports }}
    - template: jinja
  cmd.run:
    - name: 'ufw allow nomad'
    - watch:
        - file: nomad-ufw-app-config
