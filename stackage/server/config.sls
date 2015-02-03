{% set HOME = '/home/stackage' %}
{% set CONF = HOME + '/config' %}

stackage:
  user.present:
    - name: stackage
    - system: True
    - gid_from_name: True

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

