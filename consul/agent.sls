# setup consul service as an agent

{%- set home = '/home/consul' %}
{%- set user = 'consul' %}

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
        description: "Consul Agent"
        bin_path: /usr/local/bin/consul
        cmd_args: agent -config-dir {{ home }}/conf.d/ 
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
