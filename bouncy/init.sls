{%- set user = salt['pillar.get']('bouncy:runas:user', 'bouncy') %}
{%- set group = salt['pillar.get']('bouncy:runas:group', 'bouncy') %}

bouncy-executable:
  file.managed:
    - name: /usr/local/bin/bouncy
    - source: salt://bouncy/files/bouncy
    - user: root
    - group: root
    - mode: 755


bouncy-ufw:
  file.managed:
    - name: /etc/ufw/applications.d/bouncy.conf
    - source: salt://ufw/files/etc/applications.d/app_config.jinja
    - template: jinja
    - context:
        description: 'Bouncy, the HTTP to HTTPS bouncer'
        title: bouncy
        app: bouncy
        ports: '4321/tcp'
    - user: root
    - group: root
    - mode: 640
  cmd.run:
    - name: 'ufw allow bouncy'
    - unless: 'ufw status | grep bouncy'
    - require:
        - file: bouncy-executable
        - file: bouncy-service
    - watch:
        - file: bouncy-ufw


bouncy-service:
  file.managed:
    - name: /etc/init/bouncy.conf
    - source: salt://upstart/files/generic.conf
    - template: jinja
    - user: root
    - group: root
    - mode: 755
    - context:
        runas_user: {{ user }}
        runas_group: {{ group }}
        description: 'Bouncy, the HTTP to HTTPS bouncer'
        bin_path: /usr/local/bin/bouncy
        bin_opts: ''
        respawn: True
    - require:
        - file: bouncy-executable
  service.running:
    - name: bouncy
    - require:
        - cmd: bouncy-ufw
    - watch:
        - file: bouncy-executable
        - file: bouncy-service
