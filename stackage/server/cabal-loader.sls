start-stackage-cabal-loader-script:
  file.managed:
    - name: /usr/local/bin/start-stackage-cabal-loader
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
            --volume /home/stackage/server/:/opt/stackage-server  \
            stackage-server:cabal-loader



stackage-cabal-loader-upstart-config:
  file.managed:
    - name: /etc/init/stackage-cabal-loader.conf
    - user: root
    - group: root
    - contents: |
        description "Stackage Server Cabal Loader (docker container)"
        author "dev@fpcomplete.com"
        start on filesystem and started docker and started postgres
        stop on runlevel [!2345]
        respawn
        script
          /usr/bin/docker run             \
              --user="stackage"           \
              -a STDOUT                   \
              --link postgres:docker_db   \
              --volume /home/stackage/server/:/opt/stackage-server  \
              stackage-server:cabal-loader
        # /usr/local/bin/start-stackage-cabal-loader
        end script

