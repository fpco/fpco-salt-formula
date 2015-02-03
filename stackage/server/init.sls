include:
  - stackage.server.config
  - stackage.server.runtime_deps


stackage-server:
  file.managed:
    - name: /usr/local/bin/stackage-server
    - mode: 755
    - user: root
    - group: root
    - source: salt://stackage/server/files/stackage-server
  service.running:
    - name: stackage-server
    - watch:
        - file: stackage-server
        - file: stackage-server-config
        - file: stackage-server-client-key
        - file: stackage-server-postgres-config
        - file: stackage-server-upstart-config
        - file: stackage-server-static-files
    - require:
        - pkg: stackage-server-runtime-dependencies

stackage-server-client-key:
  file.managed:
    - name: /home/stackage/config/client_session_key.aes
    - source: salt://stackage/server/files/client_session_key.aes
    - user: stackage
    - group: stackage
    - mode: 640
    - require:
        - file: stackage-server-config
        - user: stackage

stackage-server-static-files:
  file.recurse:
    - name: /home/stackage/static/
    - source: salt://stackage/server/files/static/
    - user: stackage
    - group: stackage
    - dir_mode: 755
    - file_mode: 644
    - require:
        - user: stackage

stackage-server-upstart-config:
  file.managed:
    - name: /etc/init/stackage-server.conf
    - mode: 640
    - user: root
    - group: root
    - source: salt://stackage/server/files/upstart.conf
    - template: jinja
    - defaults:
        run_as_user: 'stackage'
        env: 'Staging'
        port: 3000

