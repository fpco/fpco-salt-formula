# setup consul service as a leader

{%- set home = '/home/consul' %}
{%- set user = 'consul' %}
{%- set consul = salt['pillar.get']('consul', {}) %}
{%- set bootstrap_args = '-bootstrap-expect ' + consul['leader_count'] %}

include:
  - consul.config


consul-upstart:
  file.managed:
    - name: /etc/init/consul.conf
    - source: salt://consul/files/upstart.conf
    - mode: 640
    - user: root
    - group: root
    - template: jinja
    - defaults: 
        description: "Consul Leader"
        bin_path: /usr/local/bin/consul
        cmd_args: agent -config-dir {{ home }}/conf.d/ {{ bootstrap_args }}
        run_as: {{ user }}
        home: {{ home }}
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
          server: True
