# formula to seed Salt's file_roots with a bunch of git repos
# assume there is other formula that will take care of configuring
# SaltStack master/minion with these file_roots, just focus on git checkout
#
# this formula supports _multiple_ git repos > /srv/salt/

# user to run the git checkout as
{%- set user = salt['pillar.get']('file_roots_bootstrap:user', 'root') %}
# SSH key for git checkout
{%- set ssh_key_path = salt['pillar.get']('file_roots_bootstrap:ssh_key_path', '/root/.ssh/id_rsa') %}
# where to checkout to, root path
{%- set roots_root = salt['pillar.get']('file_roots_bootstrap:roots_root', '/srv/salt') %}
# name/url/rev for each repo to use as file_roots
{%- set src_repos = salt['pillar.get']('file_roots_bootstrap:src', {}) %}

include:
  - git


# SSH key to use for git checkout
roots-ssh-key:
  file.exists:
    - name: {{ ssh_key_path }}
    - user: {{ user }}
    - group: {{ user }}
    - mode: 600

# root path for all file_roots checked out
roots-root:
  file.directory:
    - name: {{ roots_root }}
    - user: {{ user }}
    - mode: 750
    - makedirs: True


# generate the `git.latest` states for the file_roots to checkout
{%- for repo, conf in src_repos.items() %}
{%- set url = conf['url'] %}
{%- set rev = conf['rev'] %}

roots-git-{{ repo }}:
  git.latest:
    - name: {{ url }}
    - rev: {{ rev }}
    - target: {{ roots_root }}/{{ repo }}
    - user: {{ user }}
    - force: True
    - force_checkout: True
    - identity: {{ ssh_key_path }}
    - require:
        - file: roots-ssh-key
        - file: roots-root
        - pkg: git

{%- endfor %}
