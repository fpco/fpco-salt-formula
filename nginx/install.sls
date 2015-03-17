{% from 'nginx/map.jinja' import nginx with context %}
{%- set user = nginx.server.config.user or 'www-data' %}
{%- set version = nginx.install.version or 'stable' %}
{%- set pkg_name = nginx.install.pkg_name or 'nginx' %}

nginx:
  pkgrepo.managed:
    - ppa: nginx/{{ version }}
  pkg.installed:
    - name: {{ pkg_name }}
    - watch:
        - pkgrepo: nginx
  service.running:
    - name: nginx
    - enable: True
    - watch:
        - pkg: nginx
    - require:
        - user: nginx
  user.present:
    - name: {{ user }}
    - system: True
    - gid_from_name: True
