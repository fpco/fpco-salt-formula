rsyslog-salt-minion-conf:
  file.managed:
    - name: /etc/rsyslog.d/23-salt-minion.conf
    - source: salt://rsyslog/files/imfile.jinja
    - template: jinja
    - context:
        file: /var/log/salt/minion
        tag: salt-minion
        state_suffix: salt-minion
        log_level: info
        interval: 5
    - user: root
    - group: root
    - mode: 640
    - require:
        - file: rsyslog-load-imfile
    - watch_in:
        - service: rsyslog
