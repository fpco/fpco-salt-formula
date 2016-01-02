{%- set git_home = salt['pillar.get']('src:git:home', '/usr/src') %}
{%- set git_user = salt['pillar.get']('src:git:user', 'root') %}
{%- set git_group = salt['pillar.get']('src:git:group', 'root') %}
{%- set git_pubkey = salt['pillar.get']('src:git:identity_file', '/root/.ssh/id_rsa') %}


src_git_home:
  file.directory:
    - name: {{ git_home }}
    - user: {{ git_user }}
    - group: {{ git_group }}
    - mode: 0755
    - require:
        - pkg: git


{# iterate over the set of git repositories #}
{% for repo in salt['pillar.get']('src:git:repos', {}) %}
{% set r = pillar['src']['git']['repos'][repo] %}
{{ repo }}-git:
  git.latest:
    - name: {{ r.url }}
    - rev: {{ r.rev }}
    - target: {{ git_home }}/{{ repo }}/
    - user: {{ git_user }}
    - identity: {{ identity_file }}
    - require:
       - file: src_git_home
{% endfor %}

