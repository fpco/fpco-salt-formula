# setup vault service as an agent

{%- set home = '/var/lib/vault' %}
{%- set user = 'vault' %}
{%- set conf_path = '/etc/vault' %}
{%- set conf_file = conf_path ~ '/config.json' %}
{%- set config_args = ' -config ' ~ conf_file %}
{%- set default_args = 'server' ~ config_args %}
{%- set desc = 'Hashicorp Vault' %}

include:
  - vault.config


vault-upstart:
  file.managed:
    - name: /etc/init/vault.conf
    - source: salt://upstart/files/generic.conf
    - mode: 640
    - user: root
    - group: root
    - template: jinja
    - defaults:
        respawn: True
        description: {{ desc }}
        bin_path: /usr/local/bin/vault
        bin_opts: {{ default_args }}
        runas_user: {{ user }}
        runas_group: {{ user }}
        chdir: {{ home }}
  service.running:
    - name: vault
    - enable: True
    - watch:
        - file: vault-config
        - file: vault-upstart
