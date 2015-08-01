{#- setup and run the consul-template service via upstart -#}
{%- set consul_home = '/home/consul' %}
{%- set conf_path = consul_home + '/template-tool' %}
{%- set user = 'consul' %}
{%- set service_name = 'consul-template' %}

include:
  - .config


consul-tpl-upstart:
  file.managed:
    - name: /etc/init/{{ service_name }}.conf
    - source: salt://upstart/files/generic.conf
    - mode: 640
    - user: root
    - group: root
    - template: jinja
    - defaults:
        description: "Consul Template Service"
        bin_path: /usr/local/bin/consul-template
        bin_opts: -config {{ conf_path }}
        runas_user: root
        runas_group: {{ user }}
        chdir: {{ consul_home }}
        respawn: True
  service.running:
    - name: {{ service_name }}
    - enable: True
    - watch:
        - file: consul-tpl-base-config
        - file: consul-tpl-upstart
