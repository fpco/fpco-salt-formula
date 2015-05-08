# Use the rdr2tls Docker image as a proxy to an S3-backed Docker Registry.
# This provides a proxy to a read-only, static registry (no push).
#
# More details are documented:
#
#
{%- set image = salt['pillar.get']('rproxy:image', 'fpco/rdr2tls') %}
{%- set tag = salt['pillar.get']('rproxy:tag', 'latest') %}
{%- set cname = 'registry' %}
{%- set port = salt['pillar.get']('rproxy:port', '5000') %}
{%- set bucket = salt['pillar.get']('rproxy:bucket', 'registry.example.com') %}
{%- set s3_backend = 's3.amazonaws.com/' + bucket %}


docker-rproxy-image:
  docker.pulled:
    - name: {{ image }}
    - tag: latest


{%- if reset %}
docker-rproxy-reset-container:
  docker.absent:
    - name: {{ cname }}
    - require_in:
       - docker: docker-rproxy-container
{%- endif %}


docker-rproxy-container:
  docker.installed:
    - name: {{ cname }}
    - hostname: {{ salt['grains.get']('hostname') }}
    - image: {{ image }}:{{ tag }}
    - ports:
        - 127.0.0.1:{{ port }}:{{ port }}
    - command: rdr2tls -p {{ port }} -P {{ s3_backend }}
    - require:
        - docker: docker-rproxy-image


docker-rproxy-service:
  docker.running:
    - name: {{ cname }}
    - require:
        - docker: docker-rproxy-container
