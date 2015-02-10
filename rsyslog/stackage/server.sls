rsyslog-stackage-server-conf:
  file.managed:
    - name: /etc/rsyslog.d/30-stackage-server.conf
    - source: salt://rsyslog/files/imfile.jinja
    - template: jinja
    - context:
        file: /var/log/upstart/stackage-server.log
        tag: stackage-server
        state_suffix: stackage-server
        log_level: info
        interval: 5
    - user: root
    - group: root
    - mode: 640
    - require:
        - file: rsyslog-load-imfile
    - watch_in:
        - service: rsyslog

