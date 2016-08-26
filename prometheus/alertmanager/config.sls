{%- set conf_yml = '/etc/alertmanager/config.yml' %}
{%- set conf = salt['pillar.get']('alertmanager:config', False) %}

alertmanager-config:
  file.managed:
    - name: {{ conf_yml }}
    - user: root
    - group: root
    - mode: 640
    - makedirs: True
    {% if conf %}
    # source this config file from pillar
    - contents_pillar: 'alertmanager:config'
    {% else %}
    # serve up the default config
    - source: salt://prometheus/files/default_config-alertmanager.yaml
    {% endif %}


