# run the boundary setup script to install the boundary agent
# rely on the script to do the work for now, keep it simple

boundary-agent-install-script:
  file.managed:
    - name: /root/setup_boundary.sh
    - source: salt://boundary/files/setup.sh
    - user: root
    - group: root
    - mode: 750
  cmd.run:
    - name: /root/setup_boundary.sh
    - user: root
    - require:
        - file: boundary-agent-install-script

boundary-rm-install-script:
  file.absent:
    - name: /root/setup_boundary.sh
    - require:
        - cmd: boundary-agent-install-script
