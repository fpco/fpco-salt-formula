{%- set default_address = 'http://vault.service.consul:8200' %}
{%- set address = salt['pillar.get']('nomad:vault:address', default_address) %}
{%- set enabled = salt['pillar.get']('nomad:vault:enabled', 'true') %}
{%- set token = salt['pillar.get']('nomad:vault:token', False) -%}

vault {
  enabled = {{ enabled }}
  address = "{{ address }}"

  {% if token is defined %}token = "{{ token }}"{% endif %}
}
