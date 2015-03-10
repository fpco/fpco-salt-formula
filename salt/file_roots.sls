{%- set user = 'root' %}
{%- set ssh_key_path = '/root/.ssh/id_rsa' %}
{%- set url = salt['pillar.get']('salt:file_roots_src:url') %}
{%- set rev = salt['pillar.get']('salt:file_roots_src:rev') %}

include:
  - git


salt-roots:
  file.exists:
    - name: {{ ssh_key_path }}
    - user: {{ user }}
    - group: {{ user }}
    - mode: 600
  git.latest:
    - name: {{ url }}
    - rev: {{ rev }}
    - target: /srv/salt
    - user: {{ user }}
    - force: True
    - force_checkout: True
    - identity: {{ ssh_key_path }}
    - require:
        - file: salt-roots
        - pkg: git
