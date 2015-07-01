{%- set repo_root = '/root/consulacl' %}
{%- set repo_url = 'https://github.com/CiscoCloud/consulacl' %}

include:
  - go

consulacl:
  git.latest:
    - name: {{ repo_url }}
    - target: {{ repo_root }}
  cmd.run:
    - name: make
    - cwd: {{ repo_root }}
    - env:
        - GOPATH: /root/.go
    - require:
        - git: consulacl
