remove-insecure-ntpd:
  cmd.run:
    - name: "apparmor_parser -R /etc/apparmor.d/usr.sbin.ntpd && apt-get purge ntp"
