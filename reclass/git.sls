{%- set default_git_url = 'git+https://github.com/max-arnold/reclass.git@maintenance' %}
{%- set git_url = salt['pillar.get']('reclass:git_url', default_git_url) %}

include:
  - python.pip

reclass:
  pip.installed:
    - name: {{ git_url }}
