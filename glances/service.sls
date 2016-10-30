{% set browser = salt['pillar.get']('glances:browser', False) %}
{% set agent = salt['pillar.get']('glances:agent', True) %}
{% set webui = salt['pillar.get']('glances:webui', False) %}
{% set docker = salt['pillar.get']('glances:docker', False) %}
{% set opts = salt['pillar.get']('glances:opts', '') %}
{%- if agent %}
{% set opts = opts ~ '-s ' %}
{% set glances_ip = salt['grains.get']('ip4_interfaces')['eth0'][0] %}
{%- endif %}
{%- if webui %}
{% set opts = opts ~ '-w ' %}
{% set glances_ip = '127.0.0.1' %}
{%- endif %}
{%- if browser %}
{% set opts = opts ~ '--browser ' %}
{% set glances_ip = '127.0.0.1' %}
{%- endif %}

glances-upstart:
  file.managed:
    - name: /etc/init/glances.conf
    - template: jinja
    {%- if docker %}
    - source: salt://docker/files/upstart-tpl-container-as-a-service.sls
    - context:
        desc: Run the glances agent as a docker container
        author: the-ops-ninjas@fpcomplete.com
        container_name: glances
        img: nicolargo/glances
        tag: latest
        ip: {{ glances_ip }}
        host_port: '{% if webui %}61208-{% endif %}61209'
        container_port: '{% if webui %}61208-{% endif %}61209'
        cmd: /usr/local/bin/glances
        docker_args:
          - '-e GLANCE_OPTS="{{ opts }}"'
          - '--pid=host'
          - '--volume /var/run/docker.sock:/var/run/docker.sock:ro'
    {%- else %}
    - source: salt://upstart/files/generic.conf
    - context:
        description: Run the glances agent
        respawn: False
        runas_user: glances
        runas_group: glances
        bin_path: /usr/local/bin/glances
        bin_opts: "--bind {{ glances_ip }} {{ mode }}"
    {%- endif %}
  service.running:
    - name: glances
    - enable: True
    - watch:
        - file: glances-upstart
