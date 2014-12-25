{% set HOME = '/home/stackage/server' %}
{% set CONF = HOME + '/config' %}

stackage-server-image:
  docker.built:
    - name: stackage-server:run
    - path: /home/ubuntu/dockerfile-experiments/stackage-server/run/


stackage-server:
  user.present:
    - name: stackage
    - system: True
    - gid_from_name: True
  # create a container, build if it does not exist
# docker.installed:
#   - name: stackage-server
#   - image: stackage-server:run
#   - user: stackage
#   - detach: True
#   - ports:
#       - 3000:3000
#   - volumes:
#       - {{ HOME }}:/opt/stackage-server/:ro
#   - watch:
#       - docker: stackage-server-image
#       - file: stackage-server-config
#       - file: stackage-postgres-config
# service.running:
#   - name: stackage-server
#   - watch:
#       - file: stackage-server-config
#       - file: stackage-postgres-config
#       - file: stackage-upstart-config
#       - docker: stackage-server
#   - require:
#       - file: stackage-upstart-config


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
    - contents: |
        Default: &defaults
          host: "*4" # any IPv4 host
          port: 3000
          approot: "http://beta.stackage.org"
          hackage-root: http://hackage.fpcomplete.com
          admin-users:
            - fpcomplete
          # google-auth:
            # client-id: foo
            # client-secret: bar

        Development:
          <<: *defaults
          blob-store: file:dev-blob-store

        Testing:
          <<: *defaults

        Staging:
          <<: *defaults
          blob-store:
            type: aws
            local: /tmp/stackage-server
            access: someaccesskey
            secret: somesecretkey
            bucket: stackage-server-beta


        Production:
          #approot: "http://www.example.com"
          <<: *defaults
          blob-store: file:/tmp/stackage-server

        S3-backed storage:
          blob-store:
            type: aws
            local: /tmp/stackage-server
            access: someaccesskey
            secret: somesecretkey
            bucket: stackage-server-beta



stackage-postgres-config:
  file.managed:
    - name: {{ CONF }}/postgresql.yml
    - user: stackage
    - group: root
    - require:
        - file: stackage-config-path
    - contents: |
        Default: &defaults
          user: stackage_server_beta
          password: stackage_server_beta
          host: docker_db
          port: 5432
          database: stackage_server_beta
          poolsize: 10

        Development:
          <<: *defaults

        Testing:
          database: stackage_server_test
          <<: *defaults

        Staging:
          poolsize: 100
          <<: *defaults

        Production:
          database: stackage_server_production
          poolsize: 100
          <<: *defaults


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
            --volume /home/stackage/server/:/opt/stackage-server  \
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
              --volume /home/stackage/server/:/opt/stackage-server  \
              stackage-server:run
        # /usr/local/bin/start-stackage-server
        end script
#   - source: salt://stackage/server/files/etc/init/stackage-server.conf
