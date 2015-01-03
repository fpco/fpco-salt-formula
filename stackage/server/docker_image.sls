stackage-server-image:
  docker.built:
    - name: stackage-server:run
    - path: /home/stackage/dockerfiles/stackage-server/run/
    - require:
        - user: stackage-server
