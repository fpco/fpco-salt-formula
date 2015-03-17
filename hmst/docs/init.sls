{% from 'nginx/map.jinja' import nginx with context %}

{%- set docs_root = '/var/www' %}

include:
  - nginx.config


nginx-remove-default-vhost:
  file.absent:
    - name: {{ nginx.server.vhost_enabled }}/default


hmst-docs-root:
  file.directory:
    - name: {{ docs_root }}
    - user: www-data
    - group: www-data
    - mode: 570
    - makedirs: True


hmst-docs-vhost-config:
  file.managed:
    - name: {{ nginx.server.vhost_available }}/hmst-docs
    - source: salt://nginx/files/vhost.jinja
    - template: jinja
    - context:
        config: {{ nginx.vhosts.managed.hmst_docs.config|json() }}
    - user: root
    - group: {{ nginx.server.config.user }}
    - mode: 640
    - watch_in:
        - service: nginx
    - require:
        - file: nginx-config
        - file: nginx-remove-default-vhost


hmst-docs-vhost-enabled:
  file.symlink:
    - name: {{ nginx.server.vhost_enabled }}/hmst-docs
    - target: {{ nginx.server.vhost_available }}/hmst-docs
    - watch_in:
        - service: nginx
    - require:
        - file: hmst-docs-root
        - file: hmst-docs-vhost-config

