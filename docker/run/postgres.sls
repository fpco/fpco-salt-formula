start-postgres-testing-container-script:
  file.managed:
    - name: /usr/local/bin/start-postgres-testing-container
    - user: root
    - group: stackage
    - mode: 0750
    - contents: |
        #!/bin/sh
        DATA=/var/postgres/
        IMAGE=paintedfox/postgresql
        /usr/bin/docker run             \
            -a STDOUT                   \
            --restart=no                \
            --rm                        \
            --name postgres             \
            --volume $DATA:/data        \
            $IMAGE


postgres-upstart-config:
  file.managed:
    - name: /etc/init/postgres.conf
    - user: root
    - group: root
    - require:
        - file: start-postgres-testing-container-script
    - contents: |
        description "Postgres (docker container)"
        author "dev@fpcomplete.com"
        start on filesystem and started docker
        stop on runlevel [!2345]
        respawn
        script
          /usr/local/bin/start-postgres-testing-container
        end script


postgres:
  service.running:
    - name: postgres
    - enable: True
    - require:
        - file: postgres-upstart-config


{% set PG_HOME = '/var/postgres' %}
#postgres-container:
#  docker.installed:
#    - name: postgres
#    - image: paintedfox/postgresql
#    - user: stackage
#    - command:
#    - ports:
#       - 127.0.0.1:5432:5432
#    - volumes:
#       - {{ PG_HOME }}:/data
#    - environment:
#       - USER: "$USER"
#       - DB: "$DBNAME"
#       - PASS: "$(pwgen -s -1 16)"
