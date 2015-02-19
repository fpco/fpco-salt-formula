{% set HOME = '/home/stackage' %}
{% set CONF = HOME + '/config' %}

include:
  - stackage.server.user

# this could do a recurse on files/directories to ensure correct modes
# right now we rely on the archive.extracted state to do that for us
stackage-server-config-path:
  file.directory:
    - name: {{ CONF }}
    - makedirs: True
    - user: stackage
    - group: stackage
    - mode: 750
    - require:
        - user: stackage
        - file: stackage
        - archive: stackage-release


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

