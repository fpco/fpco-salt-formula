{%- set default_address = 'http://vault.service.consul:8200' %}
{%- set address = salt['pillar.get']('nomad:vault:address', default_address) %}
{%- set create_from_role = salt['pillar.get']('nomad:vault:create_from_role', False) %}
{%- set enabled = salt['pillar.get']('nomad:vault:enabled', 'true') %}
{%- set token = salt['pillar.get']('nomad:vault:token', False) -%}

vault {
  address = "{{ address }}"
  {% if create_from_role is defined %}create_from_role = "{{ create_from_role }}"{% endif %}
  enabled = {{ enabled }}
  {% if token is defined %}token = "{{ token }}"{% endif %}
}
