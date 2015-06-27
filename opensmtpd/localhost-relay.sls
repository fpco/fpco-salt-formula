{% set hostname = salt['pillar.get']('opensmtpd:relay:hostname') %}
{% set smtp_port   = salt['pillar.get']('opensmtpd:relay:upstream:port') %}
{% set smtp_user   = salt['pillar.get']('opensmtpd:relay:upstream:user') %}
{% set smtp_pass   = salt['pillar.get']('opensmtpd:relay:upstream:pass') %}
{% set smtp_server = salt['pillar.get']('opensmtpd:relay:upstream:host') %}


include:
  - opensmtpd.install

smtpd-config:
  file.managed:
    - name: /etc/smtpd.conf
    - template: jinja
    - source: salt://opensmtpd/files/smtpd.conf
    - user: root
    - group: opensmtpd
    - mode: 640
    - context:
        hostname: {{ hostname }}
        server: {{ smtp_server }}
        port: {{ smtp_port }}


secrets:
  file.managed:
    - name: /etc/smtp-secrets
    - source: salt://opensmtpd/files/secrets
    - template: jinja
    - user: root
    - group: opensmtpd
    - mode: 640
    - context:
        username: {{ smtp_user }}
        password: {{ smtp_pass }}


opensmtpd-service:
  service.running:
    - name: opensmtpd
    - watch:
        - file: secrets
        - file: smtpd-config
        - pkg: opensmtpd
