# Run the Prometheus Docker image as a service
#
# More details are documented in pillar:
{%- set image = salt['pillar.get']('prometheus:image', 'prom/prometheus') %}
{%- set tag = salt['pillar.get']('prometheus:tag', 'latest') %}
{%- set port = salt['pillar.get']('prometheus:port', '9090') %}
{%- set home = salt['pillar.get']('prometheus:home', '/prometheus') %}
{%- set conf = salt['pillar.get']('prometheus:config', False) %}

{%- set cname = 'prometheus' %}

prometheus-config:
  file.managed:
    - name: /etc/prometheus.yml
    - user: root
    - group: root
    - mode: 644
    {% if conf %}
    # source this config file from pillar
    - contents_pillar: 'prometheus:config'
    {% else %}
    # serve up the default config
    - source: salt://prometheus/files/default_config.yaml
    {% endif %}


prometheus-upstart:
  file.managed:
    - name: /etc/init/{{ cname }}.conf
    - user: root
    - group: root
    - mode: 644
    - source: salt://docker/files/upstart-tpl-container-as-a-service.sls
    - template: jinja
    - context:
        desc: Prometheus Monitoring Service
        author: the-ops-ninjas@fpcomplete.com
        # the name of the container instance
        container_name: {{ cname }}
        # the Docker image to use
        img: {{ image }}
        # the image tag to reference
        tag: {{ tag }}
        # ip/port mapping
        docker_args:
          - '--publish 127.0.0.1:{{ port }}:9090'
          - '--volume /etc/prometheus.yml:/etc/prometheus/prometheus.yml'
          - '--volume {{ home }}:/prometheus-data'
        respawn_forever: True
    - require:
        - file: prometheus-config
  service.running:
    - name: prometheus
    - enable: True
    - watch:
        - file: prometheus-upstart
        - file: prometheus-config

