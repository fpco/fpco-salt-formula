# Run the alertmanager Docker image as a service
#
# More details are documented in pillar:
{%- set image = salt['pillar.get']('alertmanager:image', 'prom/alertmanager') %}
{%- set tag = salt['pillar.get']('alertmanager:tag', 'latest') %}
{%- set default_ip = salt['grains.get']('ip4_interfaces')['eth0'][0] %}
{%- set ip = salt['pillar.get']('alertmanager:ip', default_ip) %}
{%- set port = salt['pillar.get']('alertmanager:port', '9093') %}
{%- set conf_dir = '/etc/alertmanager' %}
{%- set tpl_dir = conf_dir ~ '/templates' %}
{%- set conf_yml = conf_dir ~ '/alertmanager.yml' %}

{%- set cname = 'alertmanager' %}

include:
  - .config

alertmanager-templates:
  file.directory:
    - name: {{ tpl_dir }}
    - user: root
    - group: root
    - makedirs: True
    - file_mode: 640
    - dir_mode: 750
    - recurse:
        - user
        - group
        - mode

alertmanager-upstart:
  file.managed:
    - name: /etc/init/{{ cname }}.conf
    - user: root
    - group: root
    - mode: 644
    - source: salt://docker/files/upstart-tpl-container-as-a-service.sls
    - template: jinja
    - context:
        desc: Prometheus Alertmanager Service
        author: the-ops-ninjas@fpcomplete.com
        # the name of the container instance
        container_name: {{ cname }}
        # the Docker image to use
        img: {{ image }}
        # the image tag to reference
        tag: {{ tag }}
        # ip/port mapping
        docker_args:
          - '--net host'
          - '--publish {{ ip }}:{{ port }}:9093'
          - '--volume {{ conf_yml }}:/etc/alertmanager/config.yml'
          - '--volume {{ tpl_dir }}:/etc/alertmanager/templates'
        respawn_forever: True
    - require:
        - file: alertmanager-config
  service.running:
    - name: alertmanager
    - enable: True
    - watch:
        - file: alertmanager-upstart
        - file: alertmanager-config
        - file: alertmanager-templates

