# manage the vault config file, leave dependents to vault.init

include:
  - vault.user

{%- set conf_path = '/etc/vault' %}
{%- set user = 'vault' %}


vault-conf.d:
  file.directory:
    - name: {{ conf_path }}
    - user: {{ user }}
    - group: {{ user }}
    - mode: 750
    - makedirs: True

vault-config:
  file.managed:
    - name: {{ conf_path }}/config.hcl
    - source: salt://vault/files/config.hcl
    - user: {{ user }}
    - group: {{ user }}
    - mode: 640
    - template: jinja
    - require:
        - file: vault-conf.d
