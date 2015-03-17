{% from 'nginx/map.jinja' import nginx with context %}

{%- set conf_root = '/etc/nginx' %}
{%- set group = nginx.server.config.user or 'www-data' %}

include:
  - nginx.install


nginx-vhost-available:
  file.directory:
    - name: {{ conf_root }}/sites-available
    - user: root
    - group: {{ group }}
    - mode: 750
    - require:
        - pkg: nginx

nginx-vhost-enabled:
  file.directory:
    - name: {{ conf_root }}/sites-enabled
    - user: root
    - group: {{ group }}
    - mode: 750
    - require:
        - pkg: nginx


nginx-config:
  file.managed:
    - name: {{ conf_root }}/nginx.conf
    - source: salt://nginx/files/nginx.jinja
    - template: jinja
    - context:
        config: {{ nginx.server.config|json() }}
    - user: root
    - group: {{ group }}
    - mode: 640
    - require:
        - pkg: nginx
    - watch_in:
        - service: nginx
