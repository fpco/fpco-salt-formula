rsyslog-stackage-nightly-build-conf:
  file.managed:
    - name: /etc/rsyslog.d/30-stackage-nightly-build.conf
    - source: salt://rsyslog/files/imfile.jinja
    - template: jinja
    - context:
        file: /var/log/upstart/stackage-nightly.log
        tag: stackage-nightly-build
        state_suffix: stackage-nightly-build
        log_level: info
        interval: 5
    - user: root
    - group: root
    - mode: 640
    - require:
        - file: rsyslog-load-imfile
    - watch_in:
        - service: rsyslog


