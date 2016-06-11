{#- set the service as either running, disabled, or dead #}
{%- set status = salt['pillar.get']('salt:minion:service:status', 'dead') %}
{#- boolean - if enabled, the service starts on boot #}
{%- set enabled = salt['pillar.get']('salt:minion:service:enabled', False) %}
{#- pull hostname from pillar, fallback to the hostname from salt #}
{%- set hostname = salt['pillar.get']('hostname', grains['host']) %}
{#- the id (name) of the minion, fallback to hostname if not set #}
{%- set mid = salt['pillar.get']('salt:minion:id', hostname) %}
{#- the base path for salt configuration is hardcoded for now #}
{%- set config_path = '/etc/salt' %}

salt-minion:
  pkg.installed:
    - name: salt-minion
  file.managed:
    - name: {{ config_path }}/minion.d/extra.conf
    {#- source the contents of extra.conf from this pillar key #}
    - contents_pillar: salt:minion:config
    - allow_empty: True
  service:
    - {{ status }}
    - enable: {{ enabled }}
    - watch:
        - pkg: salt-minion
        - file: salt-minion
        - file: salt-minion-id

salt-minion-id:
  file.managed:
    - name: {{ config_path }}/minion_id
    - contents: {{ mid }}
