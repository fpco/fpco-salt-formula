{%- set image = salt['pillar.get']('bouncy:image', 'fpco/rdr2tls') %}
{%- set tag = salt['pillar.get']('bouncy:tag', 'latest') %}
{%- set port = salt['pillar.get']('bouncy:port', '8080') %}
{%- set host_ip = salt['pillar.get']('bouncy:ip', '0.0.0.0') %}
{%- set opts = salt['pillar.get']('bouncy:opts', '') %}
{%- set cname = 'bouncy' %}

bouncy-ufw:
  file.managed:
    - name: /etc/ufw/applications.d/bouncy.conf
    - source: salt://ufw/files/etc/ufw/applications.d/app_config.jinja
    - template: jinja
    - context:
        description: 'Bouncy, the HTTP to HTTPS bouncer'
        title: bouncy
        app: bouncy
        ports: '{{ port }}/tcp'
    - user: root
    - group: root
    - mode: 640
  cmd.run:
    - name: 'ufw allow bouncy'
    - unless: 'ufw status | grep bouncy'
    - require:
        - file: bouncy-service
    - watch:
        - file: bouncy-ufw


bouncy-service:
  file.managed:
    - name: /etc/init/{{ cname }}.conf
    - user: root
    - group: root
    - mode: 644
    - source: salt://docker/files/upstart-tpl-container-as-a-service.sls
    - template: jinja
    - context:
        desc: 'Bouncy, the HTTP to HTTPS bouncer'
        author: the-ops-ninjas@fpcomplete.com
        # the name of the container instance
        container_name: {{ cname }}
        # the Docker image to use
        img: {{ image }}
        # the image tag to reference
        tag: {{ tag }}
        # ip/port mapping  
        ip: {{ host_ip }}
        host_port: {{ port }}
        container_port: 8080
        cmd: rdr2tls {{ opts }}
  service.running: 
    - name: {{ cname }}
    - enable: True
    - watch:
        - file: bouncy-service
    - require:
        - file: bouncy-ufw
        - cmd: bouncy-ufw
