{%- set default_version = '1.4.1' %}
{%- set version = salt['pillar.get']('reclass:version', default_version) %}

include:
  - python.pip

reclass:
  pip.installed:
    - name: reclass == {{ version }}
    - require:
        - module: pip-refresh_modules
