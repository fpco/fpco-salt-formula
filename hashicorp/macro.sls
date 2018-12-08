# macros for rendering states used by various hashistack formula 

# installs a Hashicorp tool from .zip archive. Example:
# https://releases.hashicorp.com/nomad/0.1.2/nomad_0.1.2_linux_amd64.zip
{%- macro render_app_install_formula(app, user, group) %}
{% endmacro %}

# render formula for the hashicorp app (nomad/consul/vault)
{%- macro render_app_config_formula(app, conf_path, conf_src, user, group) %}

{{ app }}-config:
  file.managed:
    - name: {{ conf_path }}
    - source: {{ conf_src }}
    - user: {{ user }}
    - group: {{ group }}
    - mode: 640
    - template: jinja
    - require:
        - file: {{ app }}-conf.d

{{ app }}-conf.d:
  file.directory:
    - name: /etc/{{ app }}/conf.d
    - user: {{ user }}
    - group: {{ group }}
    - mode: 750
    - makedirs: True

{% endmacro %}


# formula for UFW app config
{%- macro render_app_ufw_formula(app, description, ports) %}

{{ app }}-ufw-app-config:
  file.managed:
    - name: /etc/ufw/applications.d/{{ app }}.ufw
    - source: salt://ufw/files/etc/ufw/applications.d/app_config.jinja
    - user: root
    - group: root
    - mode: 0640
    - context:
        app: {{ app }}
        title: {{ app }}
        description: {{ description }}
        ports: {{ ports }}
    - template: jinja
  cmd.run:
    - name: 'ufw allow {{ app }}'
    - watch:
        - file: {{ app }}-ufw-app-config

{% endmacro %}


# render a systemd service config and running state for the app
{%- macro render_app_service_formula(app, desc, user, group, home, bin_path, args=False, pre_start=False, env_file=False) %}

{{ app }}-service:
  file.managed:
    - name: /etc/systemd/system/{{ app }}.service
    - source: salt://systemd/files/service.tpl
    - mode: 640
    - user: root
    - group: root
    - template: jinja
    - defaults: 
        unit_params:
          Description: {{ desc }}
          Requires: network-online.target
          After: network-online.target
        service_params:
          ExecStart: {{ bin_path }} {% if args %}{{ args }}{% endif %}
          Restart: on-failure
          WorkingDirectory: {{ home }}
          User: {{ user }}
          Group: {{ group }}
          {% if pre_start %}ExecStartPre: {{ pre_start }}{% endif %}
          {% if env_file %}EnvironmentFile: {{ env_file }}{% endif %}
        install_params:
          WantedBy: multi-user.target

  service.running:
    - name: {{ app }}
    - enable: True
    - watch:
        - file: {{ app }}-config
        - file: {{ app }}-service
{% endmacro %}
