{%- set api_key = salt['pillar.get']('newrelic:apikey', 'REPLACE_WITH_REAL_KEY') %}

include:
  - newrelic.install

newrelic-sysmond:
  pkg.installed:
    - name: newrelic-sysmond
    - require:
        - pkgrepo: newrelic

  file.replace:
    - name: /etc/newrelic/nrsysmond.cfg
    - pattern: "license_key=REPLACE_WITH_REAL_KEY"
    - repl: "license_key={{ api_key }}"
    - require:
        - pkg: newrelic-sysmond

  service.running:
    - name: newrelic-sysmond
    - reload: True
    - watch:
        - pkg: newrelic-sysmond
        - file: newrelic-sysmond
