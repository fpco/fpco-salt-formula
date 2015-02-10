rsyslog-upstart-conf:
  file.managed:
    - name: /etc/rsyslog.d/49-upstart.conf
    - source: salt://rsyslog/files/imfile.jinja
    - template: jinja
    - context:
        file: /var/log/upstart/*
        tag: upstart-bucket
        state_suffix: upstart
        log_level: info
        interval: 5
    - user: root
    - group: root
    - mode: 640
    - require:
        - file: rsyslog-load-imfile
    - watch_in:
        - service: rsyslog

