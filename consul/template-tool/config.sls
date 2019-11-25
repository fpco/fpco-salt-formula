{%- set consul_home = '/etc/consul' %}
{%- set conf_path = consul_home ~ '/template-tool' %}
{%- set user = 'root' %}
{%- set group = 'consul' %}

include:
  - consul.user

consul-tpl-conf-path:
  file.directory:
    - name: {{ conf_path }}
    - user: {{ user }}
    - group: {{ group }}
    - mode: 750
    - require:
        - user: consul-user
        - file: consul-user

# if no other services provide a config, at least this one will be there
consul-tpl-base-config:
  file.managed:
    - name: {{ conf_path }}/00-consul-template.hcl
    - user: {{ user }}
    - group: {{ group }}
    - mode: 640
    - source: salt://consul/template-tool/files/base_config.hcl
    - template: jinja
    - require:
        - file: consul-tpl-conf-path
