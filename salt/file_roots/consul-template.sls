# create consul-template config for the bootstrap_formula formula

{%- set consul_home = '/home/consul' %}
{%- set user = 'consul' %}
{%- set consul_conf_path = consul_home + 'conf.d' %}
{%- set tpl_conf_path = consul_home + '/template-tool' %}
{%- set template_path = '/srv/consul-templates' %}
{%- set pillar_path = '/srv/bootstrap-formula/pillar' %}

include:
    - consul.template-tool.service


consul-template-config-bootstrap_formula:
  file.managed:
    - name: {{ tpl_conf_path }}/bootstrap_formula.hcl
    - user: {{ user }}
    - group: {{ user }}
    - mode: 640
    - contents: |
        template {
          source = "{{ template_path }}/bootstrap_formula.tpl"
          destination = "{{ pillar_path }}/bootstrap.sls"
          command = "salt-call  --local  --file-root /srv/salt/bootstrap-formula/formula  --pillar-root /srv/salt/bootstrap-formula/pillar  --config-dir /srv/salt/bootstrap-formula/conf  state.highstate"
        }
    - watch_in:
        - service: consul-tpl-service


consul-template-bootstrap_formula:
  file.managed:
    - name: {{ template_path }}/bootstrap_formula.tpl
    - user: root
    - group: root
    - mode: 640
    - contents: |{% raw %}
        {{ key "bootstrap_formula" }}
        {% endraw %}
    - watch_in:
        - service: consul-tpl-service
    - require:
        - file: consul-tpl-templates-path
