{%- macro render_keys(name, key_path, cluster_path) %}
{%- set consul_home = '/home/consul' %}
{%- set user = 'consul' %}
{%- set consul_conf_path = consul_home ~ 'conf.d' %}
{%- set tpl_conf_path = consul_home ~ '/template-tool' %}
{%- set template_path = '/srv/consul-templates' %}
{%- set kubectl_key_list = ['config', 'admin_pem', 'adminkey_pem', 'ca_pem'] %}

include:
  - consul.template-tool.service

consul-tpl-config-{{ name }}:
  file.managed:
    - name: {{ tpl_conf_path }}/{{ name }}.hcl
    - user: {{ user }}
    - group: {{ user }}
    - mode: 640
    - contents: |
        {%- for key in kubectl_key_list %}
        template {
          source = "{{ template_path }}/{{ name }}-{{ key }}.tpl"
          destination = "{{ cluster_path }}/{{ key|replace('_', '.') }}"
          command = "true"
        }{%- endfor %}
    - watch_in:
        - service: consul-tpl-service


{%- for key in kubectl_key_list %}
{#- this next one is fun to read... #}
{%- set template_contents = 'with vault "' ~ key_path ~ '"}}{{.Data.' ~ key ~ '}}' %}
consul-tpl-kubectl-{{ name }}-{{ key }}:
  file.managed:
    - name: {{ template_path }}/{{ name }}-{{ key }}.tpl
    - user: root
    - group: root
    - mode: 640
    - contents: |
        {% raw %}{{{% endraw %}{{ template_contents }}{% raw %}{{end}}{% endraw %}
    - watch_in:
        - service: consul-tpl-service
    - require:
        - file: consul-tpl-templates-path
{%- endfor %}

{% endmacro %}
