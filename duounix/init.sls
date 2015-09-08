include:
  - duounix.apt

duounix:
  pkg.installed:
    - name: duo-unix
    - require:
        - pkgrepo: duo-apt
    - refresh: True

