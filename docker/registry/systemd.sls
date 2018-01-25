{%- set desc = 'Docker Distribution (Registry v2)' %}
{%- set image = salt['pillar.get']('docker:registry:', '') %}
{%- set port_number = '5000' %}
{%- set container_name = 'registry' %}
{%- set default_envvars = {
    }
%}
{%- set envvars = salt['pillar.get']('docker:registry:envvars', default_envvars) %}
{%- set systemd_service_name = 'docker-registry' %}
{%- set cron_frequency = salt['pillar.get']('docker:registry:cron_frequency', '*/5') %}


registry-systemd:
  file.managed:
    - name: /etc/systemd/system/{{ systemd_service_name }}.service
    - user: root
    - group: root
    - mode: 644
    - source: salt://docker/files/systemd-tpl-container-as-a-service.sls
    - template: jinja
    - context:
        desc: "{{ desc }}"
        container_name: {{ container_name }} # the name of the container instance
        img: registry # the Docker image to use
        tag: 2 # the image tag to reference
        docker_args:
          - '--net=host'
          - '--publish 127.0.0.1:{{ port_number }}:{{ port_number }}'
          {%- for envvar, value in envvars.items() %}
          - '-e {{ envvar }}="{{ value }}"'
          {%- endfor %}
  service.running:
    - name: {{ systemd_service_name }}
    - enable: True
    - watch:
        - file: registry-systemd
  cron.present:
    - name: salt-call --local state.sls docker.registry.systemd
    - identifier: salt-call-apply-registry-formula
    - user: root
    - hour: '*'
    - minute: '{{ cron_frequency }}'


registry-ufw-app-config:
  file.managed:
    - name: /etc/ufw/applications.d/{{ container_name }}.ufw
    - source: salt://ufw/files/etc/ufw/applications.d/app_config.jinja
    - user: root
    - group: root
    - mode: 0640
    - context:
        app: {{ container_name }}
        title: {{ desc }}
        description: "{{ desc }}"
        ports: {{ port_number }}
    - template: jinja
  cmd.run:
    - name: 'ufw allow {{ container_name }}'
    - unless: 'ufw status | grep {{ container_name }}'
    - watch:
        - file: registry-ufw-app-config
