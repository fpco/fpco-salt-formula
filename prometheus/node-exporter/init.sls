# Use the prometheus Docker image as a proxy to an S3-backed Docker Registry.
# This provides a proxy to a read-only, static registry (no push).
#
# More details are documented:
#
#
{%- set image = salt['pillar.get']('node_exporter:image', 'prom/node-exporter') %}
{%- set tag = salt['pillar.get']('node_exporter:tag', 'latest') %}
{%- set port = salt['pillar.get']('node_exporter:port', '9100') %}
{%- set home = salt['pillar.get']('node_exporter:home', '/prometheus') %}
{%- set default_ip = salt['grains.get']('ipv4')[1] %}
{%- set ip = salt['pillar.get']('prometheus:ip', default_ip) %}

{%- set cname = 'pnode_exporter' %}


prometheus-node_exporter-upstart:
  file.managed:
    - name: /etc/init/{{ cname }}.conf
    - user: root
    - group: root
    - mode: 644
    - source: salt://docker/files/upstart-tpl-container-as-a-service.sls
    - template: jinja
    - context:
        desc: Export stats from this node, for Prometheus Monitoring Service
        author: the-ops-ninjas@fpcomplete.com
        # the name of the container instance
        container_name: {{ cname }}
        # the Docker image to use
        img: {{ image }}
        # the image tag to reference
        tag: {{ tag }}
        # ip/port mapping
        docker_args:
          - '--publish {{ ip }}:{{ port }}:9100'
          - '--net="host"'
  service.running:
    - name: {{ cname }}
    - enable: True
    - watch:
        - file: prometheus-node_exporter-upstart


