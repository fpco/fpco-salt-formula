include:
  - newrelic.install

newrelic-sysmond:
  file.managed:
    - name: /etc/newrelic/nrsysmond.cfg
    - source: salt://newrelic/files/nrsysmond.cfg
    - template: jinja
    - makedirs: True

  service.running:
    - name: newrelic-sysmond
    - reload: True
    - watch:
        - pkg: newrelic
        - file: newrelic-sysmond
