# manage the nomad config file, leave dependents to nomad.init

{%- set conf_path = '/etc/nomad' %}
{%- set user = 'nomad' %}


nomad-config:
  file.managed:
    - name: {{ conf_path }}/config
    - source: salt://nomad/files/config.hcl
    - user: {{ user }}
    - group: {{ user }}
    - mode: 640
    - template: jinja
    - require:
        - file: nomad-conf.d

nomad-conf.d:
  file.directory:
    - name: {{ conf_path }}/conf.d
    - user: {{ user }}
    - group: {{ user }}
    - mode: 750
    - makedirs: True
