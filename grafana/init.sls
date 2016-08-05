# Use the grafana Docker image to run grafana as a service
#
{%- set admin_pass = salt['pillar.get']('grafana:admin_pass', False) %}
{%- set image = salt['pillar.get']('grafana:image', 'grafana/grafana') %}
{%- set tag = salt['pillar.get']('grafana:tag', 'latest') %}
{%- set port = salt['pillar.get']('grafana:port', '3000') %}
{%- set default_ip = salt['grains.get']('ipv4')[1] %}
{%- set ip = salt['pillar.get']('grafana:ip', default_ip) %}
{%- set conf = salt['pillar.get']('grafana:config', False) %}
{%- set home = salt['pillar.get']('grafana:home', '/var/prometheus/grafana') %}
{%- set data_mount = home ~ '/data' %}
{%- set conf_mount = home ~ '/conf' %}

{%- set cname = 'grafana' %}

grafana-data:
  file.directory:
    - name: {{ data_mount }}
    - user: root
    - group: root
    - file_mode: 640
    - dir_mode: 750
    - makedirs: True
    - recurse:
        - user
        - group
        - mode

grafana-conf:
  file.directory:
    - name: {{ conf_mount }}
    - user: root
    - group: root
    - file_mode: 640
    - dir_mode: 750
    - makedirs: True
    - recurse:
        - user
        - group
        - mode

grafana-config:
  file.managed:
    - name: {{ conf_mount }}/grafana.ini
    - user: root
    - group: root
    - mode: 644
    {% if conf %}
    # source this config file from pillar
    - contents_pillar: 'grafana:config'
    {% else %}
    # serve up the default config
    - source: salt://grafana/files/default_config.ini
    {% endif %}
    - require:
        - file: grafana-conf

grafana-upstart:
  file.managed:
    - name: /etc/init/{{ cname }}.conf
    - user: root
    - group: root
    - mode: 644
    - source: salt://docker/files/upstart-tpl-container-as-a-service.sls
    - template: jinja
    - context:
        respawn_forever: True
        desc: Run Graphana as a service, using docker
        author: the-ops-ninjas@fpcomplete.com
        # the name of the container instance
        container_name: {{ cname }}
        # the Docker image to use
        img: {{ image }}
        # the image tag to reference
        tag: {{ tag }}
        # ip/port mapping
        docker_args:
          - '--publish {{ ip }}:{{ port }}:3000'
          - '--net="host"'
          - '--volume={{ data_mount }}:/var/lib/grafana'
          - '--volume={{ conf_mount }}:/etc/grafana'
          {% if admin_pass %}- '-e "GF_SECURITY_ADMIN_PASSWORD={{ admin_pass }}"'
          {%- endif %}
  service.running:
    - name: {{ cname }}
    - enable: True
    - watch:
        - file: grafana-upstart
    - require:
        - file: grafana-data
        - file: grafana-conf
