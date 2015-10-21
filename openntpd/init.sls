# Install, configure, and run openntpd for the host, keep it simple.
# By default, applying this formula puts the service in client mode,
# unless "openntpd:server" is True, in which case ntpd will listen on
# the first external IP (private interface on AWS).
# See the `openntpd.consul_template` formula for a client-side helper.
# apply `openntpd.drop_insecure_ntpd` 

openntpd:
  pkg.latest:
    - name: openntpd
  file.managed:
    - name: /etc/openntpd/ntpd.conf
    - template: jinja
    - source: salt://openntpd/files/ntpd.conf
    - user: root
    - group: ntpd
    - mode: 640
  service.running:
    - name: openntpd
    - watch:
        - file: openntpd
        - pkg: openntpd
