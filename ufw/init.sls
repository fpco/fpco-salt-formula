include:
  - ufw.allow_ssh


ufw:
  pkg.installed:
    - name: ufw
  file.managed:
    - name: /etc/ufw/ufw.conf
    - source: salt://ufw/files/etc/ufw/ufw.conf
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - defaults:
        enabled: 'yes'
        loglevel: low
    - require:
        - pkg: ufw
  service.running:
    - name: ufw
    - enable: True
    - require:
        - pkg: ufw
    - watch:
        - file: ufw
        - file: ufw-defaults


ufw-defaults:
  file.managed:
    - name: /etc/default/ufw
    - source: salt://ufw/files/etc/default/ufw
    - user: root
    - group: root
    - mode: 644
    - require:
        - pkg: ufw

