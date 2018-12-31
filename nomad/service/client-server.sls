# setup nomad service as an agent
# home directory for the user/service (runtime files)
{%- set home = salt['pillar.get']('nomad:home') %}
# configuration files go here
{%- set conf_path = salt['pillar.get']('nomad:config_root') %}
# primary config file
{%- set conf_file = salt['pillar.get']('nomad:config_file') %}
# config file for telemetry/metrics
{%- set metrics_config_file = salt['pillar.get']('nomad:metrics_config_file') %}
# config file for vault
{%- set vault_config_file = salt['pillar.get']('nomad:vault_config_file') %}
# cli option for nomad, path to config file
{%- set conf_opt_file = salt['pillar.get']('nomad:config_opt_file') %}
# cli option for nomad, directory for additional config files
{%- set conf_opt_dir = salt['pillar.get']('nomad:config_opt_dir') %}
# user/group to run nomad as
{%- set run_user = salt['pillar.get']('nomad:run_as_user') %}
# user/group to own files as
{%- set user = salt['pillar.get']('nomad:user') %}
{%- set group = salt['pillar.get']('nomad:group') %}

# path to the template/source rendered for the config file for nomad server service
{%- set conf_src = 'salt://nomad/files/client-server-config.hcl' %}
# cli options passed to nomad executable in the systemd unit file
{%- set nomad_args = salt['pillar.get']('nomad:systemd_bin_args') %}
# description for the service unit and ufw configuration files
{%- set desc = salt['pillar.get']('nomad:systemd_desc') %}
# name of the app, for config, systemd and ufw rendering macros
{%- set app_name = salt['pillar.get']('nomad:systemd_name') %}
{%- set nomad_bin_path = '/usr/local/bin/nomad' %}
# for the open file limit set via LimitNOFILE in the systemd unit file
{%- set open_file_limit = salt['pillar.get']('nomad:open_file_limit') %}

{%- set vault_credstash  = salt['pillar.get']('nomad:vault:credstash:enabled', False) %}
{%- set credstash_table  = salt['pillar.get']('nomad:vault:credstash:table', 'credstash') %}
{%- set credstash_region = salt['pillar.get']('nomad:vault:credstash:aws_region', False) %}
{%- set credstash_role   = salt['pillar.get']('nomad:vault:credstash:role', False) %}
{%- set token_key_path   = salt['pillar.get']('nomad:vault:credstash:token_key_path', False) %}

{%- if vault_credstash %}
{%- set pre_start_script = '/usr/local/bin/credstash_nomad.sh' %}
{%- set vault_env_file = '/etc/nomad/vault.env' %}
{%- else %}
{%- set pre_start_script = False %}
{%- set vault_env_file = False %}
{%- endif %}

{%- if vault_credstash %}
# at minimum, the vault.env file needs to exist and be owned/writable by the nomad user
nomad-vault-env:
  file.managed:
    - name: {{ vault_env_file }}
    - user: {{ user }}
    - group: {{ group }}
    - mode: 600

# nomad user can execute but not write or change the script
nomad-start-service-script:
  file.managed:
    - name: {{ pre_start_script }}
    - user: {{ user }}
    - group: {{ group }}
    - mode: 550
    - contents: |
        #!/usr/bin/env bash
        # someone please make this less ugly
        cat << EOF > {{ vault_env_file }}
        {% if vault_credstash %}
        VAULT_TOKEN=$(GCREDSTASH_TABLE={{ credstash_table }} GCREDSTASH_KMS_KEY="alias/${GCREDSTASH_TABLE}" AWS_REGION={{ credstash_region }} gcredstash get {{ token_key_path }} role={{ credstash_role }})
        {% endif %}
        EOF
        # end credstash_nomad.sh script
    - watch_in:
      - service: nomad-service
{%- endif %}

{%- from "hashicorp/macro.sls" import render_app_config_formula with context %}

{{ render_app_config_formula(app_name, conf_file, conf_src, user, group) }}

nomad-service:
  file.managed:
    - name: /etc/systemd/system/{{ app_name }}.service
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
          ExecStart: {{ nomad_bin_path }} {{ nomad_args }}
          Restart: on-failure
          WorkingDirectory: {{ home }}
          User: {{ run_user }}
          Group: {{ group }}
          {% if pre_start_script %}ExecStartPre: {{ pre_start_script }}{% endif %}
          {% if vault_env_file %}EnvironmentFile: {{ vault_env_file }}{% endif %}
          LimitNOFILE: {{ open_file_limit }}
          Environment: "GOMAXPROCS=nproc"
        install_params:
          WantedBy: multi-user.target

  service.running:
    - name: {{ app_name }}
    - enable: True
    - watch:
        - file: {{ app_name }}-config
        - file: {{ app_name }}-service

# default network interface
{%- set default_netif = 'eth0' %}
# use default net interface if the operator hasn't provided one
{%- set network_interface = salt['pillar.get']('nomad:net_if', default_netif) %}
# lookup the first IP from the network interface specified
{%- set service_ip = salt['grains.get']('ip4_interfaces')[network_interface][0] %}
#

{%- set tls = salt['pillar.get']('nomad:tls', {}) %}
{%- if tls %}
  {%- set ca_cert_path = tls['ca_file'] %}
  {%- set client_cert_path = tls['cert_file'] %}
  {%- set client_key_path = tls['key_file'] %}
{%- endif %}


nomad-addr-system-env:
  file.append:
    - name: /etc/environment
    - text: |
        NOMAD_ADDR="http://{{ service_ip }}:4646"
        {%- if tls %}
        NOMAD_CACERT="{{ ca_cert_path }}:"
        NOMAD_CLIENT_CERT="{{ client_cert_path }}:"
        NOMAD_CLIENT_KEY="{{ client_key_path }}:"
        {%- endif %}

nomad-vault-config:
  file.managed:
    - name: {{ vault_config_file }}
    - source: salt://nomad/files/vault.hcl
    - user: {{ user }}
    - group: {{ group }}
    - mode: 640
    - template: jinja
    - require:
      - file: nomad-config
    - require_in:
      - file: nomad-service
    - watch_in:
      - service: nomad-service

nomad-metrics-config:
  file.managed:
    - name: {{ metrics_config_file }}
    - source: salt://nomad/files/metrics.hcl
    - user: {{ user }}
    - group: {{ group }}
    - mode: 640
    - template: jinja
    - require:
      - file: nomad-config
    - require_in:
      - file: nomad-service
    - watch_in:
      - service: nomad-service

