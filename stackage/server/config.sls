{% set HOME = '/home/stackage/server' %}
{% set CONF = HOME + '/config' %}

stackage-server-config-path:
  file.directory:
    - name: {{ CONF }}
    - makedirs: True
    - user: stackage
    - group: stackage
    - mode: 750
    - require:
        - user: stackage


stackage-server-config:
  file.managed:
    - name: {{ CONF }}/settings.yml
    - user: stackage
    - group: root
    - mode: 640
    - require:
        - file: stackage-server-config-path
    - source: salt://stackage/server/files/settings.yml
    - template: jinja


stackage-server-postgres-config:
  file.managed:
    - name: {{ CONF }}/postgresql.yml
    - user: stackage
    - group: root
    - mode: 640
    - require:
        - file: stackage-server-config-path
    - source: salt://stackage/server/files/postgresql.yml
    - template: jinja


stackage-server-upstart-config:
  file.managed:
    - name: /etc/init/stackage-server.conf
    - mode: 640
    - user: root
    - group: root
    - source: salt://stackage/server/files/upstart.conf
