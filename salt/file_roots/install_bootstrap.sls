# user to run the git checkout as
{%- set user = salt['pillar.get']('file_roots_bootstrap:user', 'root') %}
# SSH key for git checkout
{%- set ssh_key_path = salt['pillar.get']('file_roots_bootstrap:ssh_key_path', '/root/.ssh/id_rsa') %}
# where to checkout to, root path
{%- set roots_root = salt['pillar.get']('file_roots_bootstrap:roots_root', '/srv/salt-bootstrap-formula') %}
# name/url/rev for each repo to use as file_roots
{%- set url = salt['pillar.get']('file_roots_bootstrap:url', 'git@github.com:fpco/bootstrap-salt-formula.git') %}
{%- set rev = salt['pillar.get']('file_roots_bootstrap:rev', 'master') %}


# SSH key to use for git checkout
roots-ssh-key:
  file.exists:
    - name: {{ ssh_key_path }}

# root path for file_roots bootstrap checked out
roots-root:
  file.directory:
    - name: {{ roots_root }}
    - user: {{ user }}
    - mode: 750
    - makedirs: True


# use git to install the file_roots bootstrap formula
install-salt-formula-bootstrap-formula:
  git.latest:
    - name: {{ url }}
    - rev: {{ rev }}
    - target: {{ roots_root }}
    - user: {{ user }}
    - force: True
    - force_checkout: True
    - identity: {{ ssh_key_path }}
    - require:
        - file: roots-ssh-key
        - file: roots-root
  file.managed:
    - name: /usr/local/sbin/bootstrap-salt-formula.sh
    - user: root
    - group: root
    - mode: 750
    - require:
        - git: install-salt-formula-bootstrap-formula
    - contents: |
        #!/bin/sh
        salt-call --local                                 \
                  --config-dir {{ roots_root }}/conf      \
                  --pillar-root {{ roots_root }}/pillar   \
                  --file_root {{roots_root }}/formula     \
                  state.sls salt.file_roots
  cmd.run:
    - name: 'echo "use /usr/local/sbin/bootstrap-salt-formula.sh to run the file_roots bootstrap formula"'
    - require:
        - file: install-salt-formula-bootstrap-formula
