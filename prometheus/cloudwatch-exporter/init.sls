# Use the prometheus Docker image as a proxy to an S3-backed Docker Registry.
# This provides a proxy to a read-only, static registry (no push).
#
# More details are documented:
#
#
{%- set image = salt['pillar.get']('cloudwatch_exporter:image', 'prom/cloudwatch-exporter') %}
{%- set tag = salt['pillar.get']('cloudwatch_exporter:tag', 'latest') %}
{%- set port = salt['pillar.get']('cloudwatch_exporter:port', '9106') %}
{%- set ip = salt['pillar.get']('cloudwatch_exporter:ip', '127.0.0.1') %}

{%- set cname = 'pcloudwatch_exporter' %}


prometheus-cloudwatch-exporter-upstart:
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
        ip: {{ ip }}
        host_port: {{ port }}
        container_port: 9106
        docker_args:
          - '--net="host"'
          - '--volume /etc/cloudwatch-exporter.json:/config.json'
    - require:
        - file: prometheus-cloudwatch-exporter-config
  service.running:
    - name: {{ cname }}
    - enable: True
    - watch:
        - file: prometheus-cloudwatch-exporter-upstart


prometheus-cloudwatch-exporter-config:
  file.managed:
    - name: /etc/cloudwatch-exporter.json
    - user: root
    - group: root
    - mode: 640
    - content: |
        { 
          "region": "eu-west-1",
          "metrics": [
            {"aws_namespace": "AWS/ELB", "aws_metric_name": "RequestCount",
             "aws_dimensions": ["AvailabilityZone", "LoadBalancerName"],
             "aws_dimension_select": {"LoadBalancerName": ["myLB"]},
             "aws_statistics": ["Sum"]},
          ]
        }
