{%- set api_key = salt['pillar.get']('scalyr:api_key', 'FOOBAR' ) %}

scalyr-installer:
  file.managed:
    - name: /root/install_scalyr.sh
    - user: root
    - mode: 750
    - contents: |
        #!/bin/sh
        wget -q https://www.scalyr.com/scalyr-repo/stable/latest/scalyr-repo-bootstrap_1.2.1_all.deb
        dpkg -r scalyr-repo scalyr-repo-bootstrap  # Remove any previous repository definitions, if any.
        dpkg -i scalyr-repo-bootstrap_1.2.1_all.deb
        apt-get update
        apt-get install scalyr-repo
        apt-get install scalyr-agent-2
        scalyr-agent-2-config --set-key "{{ api_key }}"
        scalyr-agent-2 start
  cmd.run:
    - name: /root/install_scalyr.sh
    - require:
        - file: scalyr-installer

