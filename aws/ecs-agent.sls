# docs: https://github.com/aws/amazon-ecs-agent
# also: https://registry.hub.docker.com/u/amazon/amazon-ecs-agent/
# 
#
# similar to..
#
# docker pull amazon/amazon-ecs-agent
# docker run --name ecs-agent -d                          \
#            -v /var/run/docker.sock:/var/run/docker.sock \
#            -v /var/log/ecs/:/log                        \
#            -v /var/lib/ecs/data:/data                   \
#            -p 127.0.0.1:51678:51678                     \
#            -e ECS_LOGFILE=/log/ecs-agent.log            \
#            -e ECS_LOGLEVEL=info                         \
#            -e ECS_DATADIR=/data                         \
#               amazon/amazon-ecs-agent:latest
#
#
# Pillar available:
#
#   enable_ecs: boolean to enable `docker.running` the `ecs-agent` container
#
#   ecs:        a dictionary of environment variables
#     env:
#       ECS_LOGFILE:  /log/ecs-agent.log
#       ECS_LOGLEVEL: info
#       ECS_DATADIR:  data
#   

{%- set data_dir = '/var/lib/ecs/data' %}
{%- set log_path = '/var/log/ecs' %}
{%- set image = 'amazon/amazon-ecs-agent' %}
{%- set tag = 'latest' %}
{%- set enabled = salt['pillar.get']('enable_ecs', False) %}
{%- set env = salt['pillar.get']('ecs:env', {}) %}


ecs-agent-image:
  docker.pulled:
    - name: {{ image }}
    - tag: latest

ecs-agent-data-dir:
  file.directory:
    - name: {{ data_dir }}
    - makedirs: True

ecs-agent-log-dir:
  file.directory:
    - name: {{ log_path }}
    - makedirs: True

ecs-agent-container:
  docker.installed:
    - name: ecs-agent
    - hostname: {{ salt['grains.get']('hostname') }}
    - image: {{ image }}:{{ tag }}
    - ports:
        - 127.0.0.1:51678:51678
    - volumes:
        - /var/run/docker.sock:/var/run/docker.sock
        - /var/log/ecs/:/log
        - /var/lib/ecs/data:/data
    {%- if env %}
    - environment: {% for e, v in env.items() %}
        {{ e }}: {{ v }}
        {%- endfor %}
    {%- endif %}
    - require:
        - docker: ecs-agent-image
        - file: ecs-agent-data-dir
        - file: ecs-agent-log-dir


{%- if enabled %}
ecs-agent-service:
  docker.running:
    - name: ecs-agent
    - require:
        - docker: ecs-agent-container
{%- endif %}
