jq:
  pkg.latest:
    - name: jq
  cmd.run:
    - name: jq --version
    - require:
        - pkg: jq
