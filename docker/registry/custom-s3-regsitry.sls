{%- set registry_name = salt['pillar.get']('s3-static-registry:name', 's3-static-docker') %}
{%- set registry_img = salt['pillar.get']('s3-static-registry:img', 'docker.fpcomplete.com/fpco/static-docker-registry') %}
{%- set registry_tag = salt['pillar.get']('s3-static-registry:tag', 'latest') %}
{%- set registry_ip = salt['pillar.get']('s3-static-registry:ip', '127.0.0.1') %}
{%- set host_port = salt['pillar.get']('s3-static-registry:port', '5000') %}
{%- set bucket_name = salt['pillar.get']('s3-static-registry:s3_bucket', registry_name) %}
{%- set access_key = salt['pillar.get']('s3-static-registry:aws_access_key') %}
{%- set secret_key = salt['pillar.get']('s3-static-registry:aws_secret_key') %}


s3-static-registry-upstart:
  file.managed:
    - name: /etc/init/{{ registry_name }}-registry.conf
    - user: root
    - group: root
    - mode: 644
    - source: salt://docker/files/upstart-tpl-container-as-a-service.sls
    - template: jinja
    - context:
        desc: S3 Docker Registry
        author: the-ops-ninjas@fpcomplete.com
        # the name of the container instance
        container_name: {{ registry_name }}
        # the Docker image to use
        img: {{ registry_img }}
        # the image tag to reference
        tag: {{ registry_tag }}
        # ip/port mapping
        ip: {{ registry_ip }}
        host_port: {{ host_port }}
        container_port: 5000
        # application env vars..
        env_vars:
          S3_BUCKET: {{ bucket_name }}
          AWS_ACCESS_KEY_ID: {{ access_key }}
          AWS_SECRET_ACCESS_KEY: {{ secret_key }}
        docker_args: |
          -e SETTINGS_FLAVOR=prod \
          -e STORAGE_PATH=/v1 \
          -e S3_BUCKET=$S3_BUCKET \
          -e AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID" \
          -e AWS_SECRET_KEY="$AWS_SECRET_ACCESS_KEY" \
  service.running:
    - name: {{ registry_name }}-registry
    - enable: True
    - watch:
        - file: s3-static-registry-upstart
