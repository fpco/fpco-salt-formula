{%- set own_ip = salt['grains.get']('ip4_interfaces:eth0')[0] %}

hmst-simulator:
  file.managed:
    - name: /etc/init/simulator.conf
    - mode: 640
    - user: root
    - group: root
    - source: salt://hpc/hmst-simulator/files/upstart.conf
    - template: jinja
    - defaults:
        bin_path: /usr/local/bin/simulator
        run_as_user: 'ubuntu'
        own_host: {{ own_ip }}
        port: 9909
        redis_host: 10.200.10.180
  service.running:
    - name: simulator
    - watch:
        - file: hmst-simulator
        - file: hmst-simulator-executable


hmst-simulator-executable:
  file.managed:
    - name: /usr/local/bin/simulator
    - mode: 755
    - user: root
    - group: root
    - source: salt://hpc/hmst-simulator/files/simulator
