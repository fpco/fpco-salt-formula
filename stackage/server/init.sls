include:
  - stackage.server.config
  - stackage.server.runtime_deps


stackage-server:
  user.present:
    - name: stackage
    - system: True
    - gid_from_name: True
  service.running:
    - name: stackage-server
    - watch:
        - file: stackage-server
        - file: stackage-server-config
        - file: stackage-server-postgres-config
        - file: stackage-server-upstart-config
    - require:
        - pkg: stackage-server-runtime-dependencies
  file.managed:
    - name: /usr/local/bin/stackage-server
    - user: root
    - group: root
    - mode: 755
    - source: salt://stackage/server/files/stackage-server
