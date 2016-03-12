{%- set image = salt['pillar.get']('docker:registry:', '') %}
{%- set port = '5000' %}
{%- set cname = 'registry' %}
{%- set host_ip = '0.0.0.0' %}
#     'REGISTRY_AUTH': 'htpasswd',
#     'REGISTRY_HTTP_HOST': 'https://registry.example.com',
#     'REGISTRY_STORAGE_S3_ACCESSKEY': 'FOOBAR',
#     'REGISTRY_STORAGE_S3_SECRETKEY': 'FOOBAR',
#     'REGISTRY_STORAGE_S3_REGION': 'FOOBAR',
#     'REGISTRY_STORAGE_S3_BUCKET': 'FOOBAR',
{%- set default_envvars = {
    }
%}
{%- set envvars = salt['pillar.get']('docker:registry:envvars', default_envvars) %}
{%- set cron_frequency = salt['pillar.get']('docker:registry:cron_frequency', '*/5') %}


registry-upstart:
  file.managed:
    - name: /etc/init/registry.conf
    - user: root
    - group: root
    - mode: 644
    - source: salt://docker/files/upstart-tpl-container-as-a-service.sls
    - template: jinja
    - context:
        desc: "Docker Distribution (Registry v2)"
        author: the-ops-ninjas@fpcomplete.com
        respawn_forever: True
        # the name of the container instance
        container_name: {{ cname }}
        # the Docker image to use
        img: registry
        # the image tag to reference
        tag: 2
        docker_args:
          - '--net host'
          - '--publish :{{ port }}'
          {%- for envvar, value in envvars.items() %}
          - '-e {{ envvar }}="{{ value }}"'
          {%- endfor %}
  service.running:
    - name: registry
    - enable: True
    - watch:
        - file: registry-upstart
  cron.present:
    - name: salt-call --local state.sls docker.registry
    - identifier: salt-call-apply-registry-formula
    - user: root
    - hour: '*'
    - minute: '{{ cron_frequency }}'


registry-ufw-app-config:
  file.managed:
    - name: /etc/ufw/applications.d/{{ cname }}.ufw
    - source: salt://ufw/files/etc/ufw/applications.d/app_config.jinja
    - user: root
    - group: root
    - mode: 0640
    - context:
        app: {{ cname }}
        title: Docker Distribution
        description: "Docker Distribution (Registry v2)"
        ports: {{ port }}
    - template: jinja
  cmd.run:
    - name: 'ufw allow {{ cname }}'
    - unless: 'ufw status | grep {{ cname }}'
    - watch:
        - file: registry-ufw-app-config
