# Use the hpc-manager docker image has the HPC UI from fpco/libraries
#
{%- set image = salt['pillar.get']('hpc_manager:image', 'fpco/hpc-manager-ui') %}
{%- set tag = salt['pillar.get']('hpc_manager:tag', 'latest') %}
{%- set port = salt['pillar.get']('hpc_manager:port', '3000') %}
{%- set approot = salt['pillar.get']('hpc_manager:approot', False) %}
{%- set redis_host = salt['pillar.get']('hpc_manager:redis_host', 'localhost') %}
{%- set prefix = salt['pillar.get']('hpc_manager:redis_prefix', False) %}

{%- set cname = 'hpc-manager' %}

hpc-manager-docker-ui:
  file.managed:
    - name: /etc/init/{{ cname }}.conf
    - user: root
    - group: root
    - mode: 644
    - source: salt://docker/files/upstart-tpl-container-as-a-service.sls
    - template: jinja
    - context:
        desc: hpc manager ui
        author: the-ops-ninjas@fpcomplete.com
        respawn_forever: True
        # the name of the container instance
        container_name: {{ cname }}
        # the Docker image to use
        img: {{ image }}
        # the image tag to reference
        tag: {{ tag }}
        # ip/port mapping
        docker_args:
          - '--publish 127.0.0.1:{{ port }}:3000'
          - '--workdir=/usr/local/lib/hpc-manager/'
          - '-e HPC_REDIS_HOST={{ redis_host }}'
          {% if prefix %}- '-e HPC_REDIS_PREFIX={{ prefix }}'{%- endif %}
          {% if approot %}- '-e APPROOT={{ approot }}'{%- endif %}
        cmd: hpc-manager
  service.running:
    - name: {{ cname }}
    - enable: True
    - watch:
        - file: hpc-manager-docker-ui

