# Use the rdr2tls Docker image as a proxy to an S3-backed Docker Registry.
# This provides a proxy to a read-only, static registry (no push).
#
# More details are documented:
#
#
{%- set image = salt['pillar.get']('rproxy:image', 'fpco/rdr2tls') %}
{%- set tag = salt['pillar.get']('rproxy:tag', 'latest') %}
{%- set port = salt['pillar.get']('rproxy:port', '5000') %}
{%- set bucket = salt['pillar.get']('rproxy:bucket', 'registry.example.com') %}
{%- set s3_baseurl = salt['pillar.get']('rproxy:s3_baseurl', 's3.amazonaws.com') %}
{%- set s3_backend = s3_baseurl + '/' + bucket %}

{%- set cname = 'docker-registry' %}

s3-proxy-docker-registry-upstart:
  file.managed:
    - name: /etc/init/{{ cname }}.conf
    - user: root
    - group: root
    - mode: 644
    - source: salt://docker/files/upstart-tpl-container-as-a-service.sls
    - template: jinja
    - context:
        desc: Docker Registry (S3 Proxy)
        author: the-ops-ninjas@fpcomplete.com
        # the name of the container instance
        container_name: {{ cname }}
        # the Docker image to use
        img: {{ image }}
        # the image tag to reference
        tag: {{ tag }}
        # ip/port mapping
        docker_args:
          - '--publish 127.0.0.1:{{ port }}:8080'
        cmd: rdr2tls -p 8080 -P {{ s3_backend }}
  service.running:
    - name: {{ cname }}
    - enable: True
    - watch:
        - file: s3-proxy-docker-registry-upstart

#docker-rproxy-image:
#  docker.pulled:
#    - name: {{ image }}
#    - tag: latest

{#-
 #{%- if reset %}
 #docker-rproxy-reset-container:
 #  docker.absent:
 #    - name: {{ cname }}
 #    - require_in:
 #       - docker: docker-rproxy-container
 #{%- endif %}
 #
 #docker-rproxy-container:
 #  docker.installed:
 #    - name: {{ cname }}
 #    - hostname: {{ salt['grains.get']('hostname') }}
 #    - image: {{ image }}:{{ tag }}
 #    - ports:
 #        - 127.0.0.1:{{ port }}:{{ port }}
 #    - command: rdr2tls -p {{ port }} -P {{ s3_backend }}
 #    - require:
 #        - docker: docker-rproxy-image
 #
 #
 #docker-rproxy-service:
 #  docker.running:
 #    - name: {{ cname }}
 #    - require:
 #        - docker: docker-rproxy-container
-#}
