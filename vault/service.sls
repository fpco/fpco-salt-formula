# setup vault service as an agent

{%- set home = '/var/lib/vault' %}
{%- set user = 'vault' %}
{%- set conf_path = '/etc/vault' %}
{%- set conf_file = conf_path ~ '/config.json' %}
{%- set config_args = ' -config ' ~ conf_file %}
{%- set default_args = 'server' ~ config_args %}
{%- set desc = 'Hashicorp Vault' %}
{%- set default_ip = salt['grains.get']('ip4_interfaces')['eth0'][0] %}
{%- set http_ip = salt['pillar.get']('vault:ip', default_ip) %}
{%- set http_port = salt['pillar.get']('vault:port', '8200') %}

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
    - require:
        - cmd: vault-enable-mlock


# see https://vaultproject.io/docs/config/index.html
vault-enable-mlock:
  cmd.run:
    - name: "setcap cap_ipc_lock=+ep $(readlink -f $(which vault))"


vault-addr-system-env:
  file.append:
    - name: /etc/environment
    - text: VAULT_ADDR="http://{{ http_ip }}:{{ http_port }}"
