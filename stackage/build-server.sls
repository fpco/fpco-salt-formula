{%- set home = salt['pillar.get']('stk_build:home', '/var/stackage') %}
{%- set ssh_auth = salt['pillar.get']('stk_build:ssh_auth', []) %}

curators:
  group.present:
    - name: curators
  user.present:
    - name: curators
    - home: {{ home }}
    - shell: /bin/bash
#   - uid:
    - usergroup: True
    - createhome: False
    - groups:
        - docker
    - require:
      - group: curators


{% for auth in ssh_auth %}
curators_ssh_auth_{{ loop.index0 }}:
  ssh_auth.present:
    - user: curators
    - name: {{ auth }}
    - require:
        - user: curators
{% endfor %}

stackage_repo:
  git.latest:
    - name: https://github.com/fpco/stackage
    - target: {{ home }}/stackage
