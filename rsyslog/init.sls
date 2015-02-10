rsyslog.d:
  file.directory:
    - name: /etc/rsyslog.d
    - user: root
    - group: root
    - mode: 755

rsyslog-load-imfile:
  file.managed:
    - name: /etc/rsyslog.d/20-immod-load.conf
    - user: root
    - group: root
    - mode: 640
    - contents: $ModLoad imfile
    - require:
        - file: rsyslog.d


rsyslog:
  service.running:
    - name: rsyslog
    - enable: True
    - require:
        - file: rsyslog.d
