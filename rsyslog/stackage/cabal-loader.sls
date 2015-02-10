rsyslog-stackage-cabal-loader-conf:
  file.managed:
    - name: /etc/rsyslog.d/30-stackage-cabal-loader.conf
    - source: salt://rsyslog/files/imfile.jinja
    - template: jinja
    - context:
        file: /var/log/cabal-loader.log
        tag: stackage-cabal-loader
        state_suffix: stackage-cabal-loader
        log_level: info
        interval: 5
    - user: root
    - group: root
    - mode: 640
    - require:
        - file: rsyslog-load-imfile
    - watch_in:
        - service: rsyslog


