{%- set default_netif = 'eth0' %}
{%- set network_interface = salt['pillar.get']('network_interface', default_netif) %}
{%- set ext_ip = salt['grains.get']('ip4_interfaces')[network_interface][0] %}
{%- set server = salt['pillar.get']('nomad:server:enabled', False) %}
{%- set tls = False %}
{%- set ca_cert_path = False %}
{%- set client_key_path = False %}
{%- set client_cert_path = False %}

{%- if server %}

nomad-addr-system-env:
  file.append:
    - name: /etc/environment
    - text: |
        NOMAD_ADDR="http://{{ ext_ip }}:4646"
        {%- if tls %}
        NOMAD_CACERT="{{ ca_cert_path }}:"
        NOMAD_CLIENT_CERT="{{ client_cert_path }}:"
        NOMAD_CLIENT_KEY="{{ client_key_path }}:"
        {%- endif %}

{%- endif %}
