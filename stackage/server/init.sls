include:
  - stackage.server.config


stackage-server-image:
  docker.built:
    - name: stackage-server:run
    - path: /home/stackage/dockerfiles/stackage-server/run/
    - require:
        - user: stackage-server


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

