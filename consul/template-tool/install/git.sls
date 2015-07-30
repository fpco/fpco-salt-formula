{%- set repo_root = '/root/consul-template' %}

consul-template:
  git.latest:
    - name: https://github.com/hashicorp/consul-template
    - rev: v0.10.0
    - target: {{ repo_root }}
    - user: root
    - force: True
    - force_checkout: True
  cmd.run:
    - name: make
    - cwd: {{ repo_root }}
    - env:
        - GOPATH: '/root/.go'
    - watch:
        - git: consul-template
  file.copy:
    - name: /usr/local/bin/consul-template
    - source: {{ repo_root }}/bin/consul-template
    - watch:
        - git: consul-template
        - cmd: consul-template
    - require:
        - cmd: consul-template
    - user: root
    - group: root
    - mode: 755
