newrelic:
  pkgrepo.managed:
    - humanname: newrelic
    - name: deb http://apt.newrelic.com/debian/ newrelic non-free
    - file: /etc/apt/sources.list.d/newrelic.list
    - keyid: 548C16BF
    - keyserver: keyserver.ubuntu.com

  pkg.installed:
    - name: newrelic-sysmond
    - require:
        - pkgrepo: newrelic
