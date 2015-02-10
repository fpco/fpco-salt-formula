rsyslog-salt-master-conf:
  file.managed:
    - name: /etc/rsyslog.d/24-salt-master.conf
    - source: salt://rsyslog/files/imfile.jinja
    - template: jinja
    - context:
        file: /var/log/salt/master
        tag: salt-master
        state_suffix: salt-master
        log_level: info
        interval: 5
    - user: root
    - group: root
    - mode: 640
    - require:
        - file: rsyslog-load-imfile
    - watch_in:
        - service: rsyslog
