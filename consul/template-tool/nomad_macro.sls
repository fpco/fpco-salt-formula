{%- macro render_job(name, template_src, context) %}

{%- set consul_home = '/home/consul' %}
{%- set user = 'consul' %}
{%- set consul_conf_path = consul_home ~ 'conf.d' %}
{%- set tpl_conf_path = consul_home ~ '/template-tool' %}
{%- set template_path = '/srv/consul-templates' %}
{%- set nomad_jobs_path = '/srv/nomad' %}
{%- set stop = "sudo nomad stop " ~ name  %}
{%- set run = "nomad run " ~ nomad_jobs_path ~ "/" ~ name ~ ".hcl" %}
{%- set cmd = stop ~ "; " ~ run  %}

include:
  - consul.template-tool.service

# consul-template config for the nomad job
consul-tpl-config-nomad-{{ name }}:
  file.managed:
    - name: {{ tpl_conf_path }}/{{ name }}.hcl
    - user: {{ user }}
    - group: root
    - mode: 640
    - contents: |
        template {
          # where consul-template will source the template from
          source = "{{ template_path }}/{{ name }}.tpl"
          # where consul-template will render (write) the template to
          destination = "{{ nomad_jobs_path }}/{{ name }}.hcl"
          # the action consul-template will take/run after rendering the template
          command = "{{ cmd }}"
        }
    - watch_in:
        - service: consul-tpl-service


# consul-template template for the nomad job
consul-tpl-template-nomad-{{ name }}:
  file.managed:
    - name: {{ template_path }}/{{ name }}.tpl
    - user: root
    - group: root
    - mode: 640
    - template: jinja
    - source: {{ template_src }}
    - context: {% for k,v in context.items() %}
        {{ k }}: {{ v }}
        {%- endfor %}
    - watch_in:
        - service: consul-tpl-service
    - require:
        - file: consul-tpl-templates-path


# ensure the file we render exists, even if not rendered by consul-template
consul-tpl-nomad-job-{{ name }}:
  file.managed:
    - name: {{ nomad_jobs_path }}/{{ name }}.hcl
    - user: nomad
    - group: root
    - mode: 640
    - makedirs: True

{% endmacro %}

