
include:
  - newrelic.install

newrelic-sysmond:
  pkg.installed:
    - name: newrelic-sysmond
    - require:
        - pkgrepo: newrelic

  file.managed:
    - name: /etc/newrelic/nrsysmond.cfg
    - source: salt://newrelic/files/nrsysmond.cfg
    - template: jinja
    - require:
        - pkg: newrelic-sysmond

  service.running:
    - name: newrelic-sysmond
    - reload: True
    - watch:
        - pkg: newrelic-sysmond
        - file: newrelic-sysmond
