{%- macro render_consul_monitor(name, cmd, template_src) %}

{%- set consul_home = '/home/consul' %}
{%- set user = 'consul' %}
{%- set consul_conf_path = consul_home + 'conf.d' %}
{%- set tpl_conf_path = consul_home + '/template-tool' %}
{%- set template_path = '/srv/consul-templates' %}
{%- set pillar_path = '/srv/pillar' %}

include:
  - consul.template-tool.service

consul-tpl-config-{{ name }}:
  file.managed:
    - name: {{ tpl_conf_path }}/{{ name }}.hcl
    - user: {{ user }}
    - group: {{ user }}
    - mode: 640
    - contents: |
        template {
          source = "{{ template_path }}/{{ name }}.tpl"
          destination = "{{ pillar_path }}/{{ name }}.sls"
          command = "{{ cmd }}"
        }
    - watch_in:
        - service: consul-tpl-service


consul-tpl-template-{{ name }}:
  file.managed:
    - name: {{ template_path }}/{{ name }}.tpl
    - user: root
    - group: root
    - mode: 640
    - source: salt://{{ template_src }}
    - watch_in:
        - service: consul-tpl-service


consul-tpl-pillar-{{ name }}:
  file.exists:
    - name: {{ pillar_path }}/{{ name }}.sls

{% endmacro %}

