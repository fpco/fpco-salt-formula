{%- set default_git_url = 'git+https://github.com/max-arnold/reclass.git@33d4d1e5a5eb1ce857fd2416aac8cacb5eb45ef7' %}
{%- set git_url = salt['pillar.get']('reclass:git_url', default_git_url) %}

include:
  - python.pip

reclass:
  pip.installed:
    - name: {{ git_url }}
