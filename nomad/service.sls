# setup nomad service as an agent

{%- set home = '/var/lib/nomad' %}
{%- set conf_path = '/etc/nomad' %}
{%- set conf_file = conf_path ~ '/config.json' %}
{%- set user = 'nomad' %}
{%- set server = salt['pillar.get']('nomad:server', False) %}
{%- set config_dir = '-config ' ~ conf_path ~ '/conf.d/' %}
{%- set default_args = 'agent ' ~ config_dir %}

{%- if server %}
  {%- set server_count = salt['pillar.get']('nomad:server_count', '3') %}
  {%- set bootstrap_args = ' -bootstrap-expect ' ~ server_count %}
  {%- set args = default_args ~ bootstrap_args %}
  {%- set desc = 'Nomad Server' %}
{%- else %}
  {%- set args = default_args %}
  {%- set desc = 'Nomad Agent' %}
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
