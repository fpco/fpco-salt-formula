# Install, configure, and run openntpd for the host, keep it simple.
# By default, applying this formula puts the service in client mode,
# unless "openntpd:server" is True, in which case ntpd will listen on
# the first external IP (private interface on AWS).
# See the `openntpd.consul_template` formula for a client-side helper.
# apply `openntpd.drop_insecure_ntpd` 
# use `openntpd:date_reset` pillar key (boolean), to hard reset date to
# sync with others immediately, rather than over time
{%- set reset = salt['pillar.get']('openntpd:date_reset', False) %}

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

openntpd_default:
  file.managed:
    - name: /etc/default/openntpd
    - user: root
    - group: root
    - mode: 644
    - watch_in:
        - service: openntpd
    - contents: |
        # /etc/default/openntpd
        #
        # Append '-s' to set the system time when starting in case the offset
        # between the local clock and the servers is more than 180 seconds.
        # For other options, see man ntpd(8).
        DAEMON_OPTS="-f /etc/openntpd/ntpd.conf {% if reset %}-s{% endif %}"
