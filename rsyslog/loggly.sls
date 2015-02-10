# setup rsyslog config for loggly

{%- set token =  salt['pillar.get']('rsyslog:token', 'TOKEN') %}
{%- set tag =  salt['pillar.get']('rsyslog:tag', 'stackage-beta') %}

include:
  - rsyslog


rsyslog-loggly-conf:
  file.managed:
    - name: /etc/rsyslog.d/22-loggly.conf
    - source: salt://rsyslog/files/loggly.conf
    - template: jinja
    - context:
        token: {{ token }}
        tag: {{ tag }}
    - user: root
    - group: root
    - mode: 640
    - require:
        - file: rsyslog.d
    - watch_in:
        - service: rsyslog
