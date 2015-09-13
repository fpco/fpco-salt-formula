# create consul-template config for the users formula

{%- set consul_home = '/home/consul' %}
{%- set user = 'consul' %}
{%- set consul_conf_path = consul_home + 'conf.d' %}
{%- set tpl_conf_path = consul_home + '/template-tool' %}
{%- set template_path = '/srv/consul-templates' %}
{%- set pillar_path = '/srv/pillar' %}


consul-template-config-users:
  file.managed:
    - name: {{ tpl_conf_path }}/users.hcl
    - user: {{ user }}
    - group: {{ user }}
    - mode: 640
    - contents: |
        template {
          source = "{{ template_path }}/users.tpl"
          destination = "{{ pillar_path }}/users.sls"
          command = "salt-call --local state.sls users"
        }
    - watch_in:
        - service: consul-tpl-upstart


consul-template-users:
  file.managed:
    - name: {{ template_path }}/users.tpl
    - user: root
    - group: root
    - mode: 640
    - contents: |{% raw %}
        {{ key "users" }}
        {% endraw %}
    - watch_in:
        - service: consul-tpl-upstart

