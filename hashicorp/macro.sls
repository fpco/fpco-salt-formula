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
{%- macro render_app_service_formula(app, description, user, group, home, args) %}

{{ app }}-service:
  file.managed:
    - name: /etc/systemd/system/{{ app }}.service
    - source: salt://systemd/files/basic.service.tpl
    - mode: 640
    - user: root
    - group: root
    - template: jinja
    - defaults: 
        description: {{ description }}
        bin_path: /usr/local/bin/{{ app }}
        bin_opts: {{ args }}
        runas_user: {{ user }}
        runas_group: {{ group }}
        home: {{ home }}
        requires: network-online.target
  service.running:
    - name: {{ app }}
    - enable: True
    - watch:
        - file: {{ app }}-config
        - file: {{ app }}-service
{% endmacro %}
