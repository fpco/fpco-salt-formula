# create consul-template config for the bootstrap_formula formula

{%- set consul_home = '/home/consul' %}
{%- set user = 'consul' %}
{%- set consul_conf_path = consul_home + 'conf.d' %}
{%- set tpl_conf_path = consul_home + '/template-tool' %}
{%- set template_path = '/srv/consul-templates' %}
{%- set git_root = '/srv/bootstrap-salt-formula' %}

include:
    - consul.template-tool.service


consul-template-config-bootstrap_salt_formula:
  file.managed:
    - name: {{ tpl_conf_path }}/bootstrap_salt_formula.hcl
    - user: {{ user }}
    - group: {{ user }}
    - mode: 640
    - contents: |
        template {
          source = "{{ template_path }}/bootstrap_salt_formula.tpl"
          destination = "{{ git_root }}/pillar/bootstrap.sls"
          command = "salt-call  --local  --file-root {{ git_root }}/formula  --pillar-root {{ git_root }}/pillar  --config-dir {{ git_root }}/conf  state.highstate"
        }
    - watch_in:
        - service: consul-tpl-service


consul-template-bootstrap_salt_formula:
  file.managed:
    - name: {{ template_path }}/bootstrap_salt_formula.tpl
    - user: root
    - group: root
    - mode: 640
    - contents: |{% raw %}
        {{ key "bootstrap_salt_formula" }}
        {% endraw %}
    - watch_in:
        - service: consul-tpl-service
    - require:
        - file: consul-tpl-templates-path
