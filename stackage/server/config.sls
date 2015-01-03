{% set HOME = '/home/stackage/server' %}
{% set CONF = HOME + '/config' %}

stackage-config-path:
  file.directory:
    - name: {{ CONF }}
    - makedirs: True
    - user: stackage
    - group: stackage
    - require:
        - user: stackage


stackage-server-config:
  file.managed:
    - name: {{ CONF }}/settings.yml
    - user: stackage
    - group: root
    - require:
        - file: stackage-config-path
    - source: salt://stackage/server/files/settings.yml
    - template: jinja


stackage-postgres-config:
  file.managed:
    - name: {{ CONF }}/postgresql.yml
    - user: stackage
    - group: root
    - require:
        - file: stackage-config-path
    - source: salt://stackage/server/files/postgresql.yml
    - template: jinja

start-stackage-server-script:
  file.managed:
    - name: /usr/local/bin/start-stackage-server
    - user: root
    - group: stackage
    - mode: 0750
    - contents: |
        #!/bin/sh
        /usr/bin/docker run             \
            --user="stackage"           \
            --restart=no                \
            -a STDOUT                   \
            --link postgres:docker_db   \
            --publish :80:3000          \
            --volume {{ HOME }}:/opt/stackage-server  \
            stackage-server:run


stackage-upstart-config:
  file.managed:
    - name: /etc/init/stackage-server.conf
    - user: root
    - group: root
    - contents: |
        description "Stackage Server (docker container)"
        author "dev@fpcomplete.com"
        start on filesystem and started docker and started postgres
        stop on runlevel [!2345]
        respawn
        #env HOME /home/stackage/server/
        script
          /usr/bin/docker run             \
              --user="stackage"           \
              --restart=no                \
              -a STDOUT                   \
              --link postgres:docker_db   \
              --publish :80:3000          \
              --volume {{ HOME }}:/opt/stackage-server  \
              stackage-server:run
        # /usr/local/bin/start-stackage-server
        end script
#   - source: salt://stackage/server/files/etc/init/stackage-server.conf

