{%- set home = salt['pillar.get']('stack:home', '/root') %}
{%- set user = salt['pillar.get']('stack:user', 'root') %}
{%- set group = salt['pillar.get']('stack:group', 'root') %}

stack-config:
  file.managed:
    - name: {{ home }}/.stack/stack.yaml
    - user: {{ user }}
    - group: {{ group }}
    - mode: 640
    - makedirs: True
    - contents: |
        docker:
          auto-pull: true
