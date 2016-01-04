{#- the base path for salt configuration is hardcoded for now #}
{%- set config_path = '/etc/salt' %}

salt-master-config:
  file.serialize:
    - name: {{ config_path }}/master.d/00_master.conf
    - dataset_pillar: 'salt:master'
    - formatter: YAML
    - makedirs: True
    - user: root
    - group: root
    - mode: 640
