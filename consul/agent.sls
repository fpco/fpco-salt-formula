# setup consul service as an agent

{%- set home = '/home/consul' %}
{%- set user = 'consul' %}
{%- set consul = salt['pillar.get']('consul', {}) %}

include:
  - consul

consul-upstart:
  file.managed:
    - name: /etc/init/consul.conf
    - source: salt://consul/files/upstart.conf
    - mode: 640
    - user: root
    - group: root
    - template: jinja
    - defaults: 
        description: "Consul Agent"
        bin_path: /usr/local/bin/consul
        cmd_args: agent
        run_as: {{ user }}
        chdir: {{ home }}
        webui: False
  service.running:
    - name: consul
    - enable: True
    - watch:
        - file: consul-bin
        - file: consul-user
        - file: consul-config
        - file: consul-upstart

extend:
  consul-config:
    file.managed:
      - context:
          leaders: {%- for leader_ip in consul['leaders'] %}
            - {{ leader_ip }}
            {% endfor %}
          secret_key: {{ consul['secret_key'] }}

