{#- setup and run the consul-template service via upstart -#}
{%- set consul_home = '/home/consul' %}
{%- set conf_path = consul_home ~ '/template-tool' %}
{%- set user = 'consul' %}
{%- set service_name = 'consul-template' %}
{%- set template_path = '/srv/consul-templates' %}
{%- set log_level = salt['pillar.get']('consul_template:log_level', 'info') %}

include:
  - .config
  - consul.reload


consul-tpl-service:
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
        bin_opts: -config {{ conf_path }} -log-level={{ log_level }}
        runas_user: root
        runas_group: {{ user }}
        chdir: {{ consul_home }}
        respawn: True
  service.running:
    - name: {{ service_name }}
    - enable: True
    - watch:
        - file: consul-tpl-base-config
        - file: consul-tpl-service
        - file: consul-tpl-templates-path


consul-tpl-templates-path:
  file.directory:
    - name: {{ template_path }}
    - user: {{ user }}
    - group: root
    - mode: 750


consul-tpl-consul-service:
  file.managed:
    - name: /home/consul/conf.d/consul_template_service.json
    - user: consul
    - group: consul
    - mode: 640
    - contents: |
        {
          "service": {
            "name": "consul-template",
            "tags": ["core", "consul"],
            "checks": [
              {
                "script": "service consul-template status",
                "interval": "30s"
              }
            ]
          }
        }
    # reload consul config after this service.json is in place
    - require_in:
        - cmd: consul-service-check-reload

