{#- pull hostname from pillar, fallback to the hostname from salt #}
{%- set hostname = salt['pillar.get']('hostname', grains['host']) %}
{#- the id (name) of the minion, fallback to hostname if not set #}
{%- set mid = salt['pillar.get']('salt:minion:id', hostname) %}
{#- the base path for salt configuration is hardcoded for now #}
{%- set config_path = '/etc/salt' %}


salt-minion-config:
  file.serialize:
    - name: {{ config_path }}/minion.d/00_minion.conf
    - dataset_pillar: 'salt:minion'
    - formatter: YAML
    - makedirs: True
    - user: root
    - group: root
    - mode: 640

salt-minion-id:
  file.managed:
    - name: {{ config_path }}/minion_id
    - contents: {{ mid }}
