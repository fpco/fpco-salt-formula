glances:
  pkg.installed:
    - pkgs:
        - libssl-dev
        - libpython2.7-dev
  pip.installed:
    - name: glances
    - require:
        - pkg: glances
  user.present:
    - name: glances
    - uid: 991
    - system: True
    - groups:
        - docker
    - shell: /usr/sbin/nologin
  file.managed:
    - name: /etc/ufw/applications.d/glances
    - template: jinja
    - source: salt://ufw/files/etc/ufw/applications.d/app_config.jinja
    - context:
        app: glances
        title: glances
        description: allow glances collection agent to be accessed by browser clients
        ports: 61209
  cmd.run:
    - name: ufw allow glances
    - require:
        - file: glances


{% set pip_packages = ['bottle', 'zeroconf'] %}
{% for pkg in pip_packages %}
glances-pip-{{pkg}}:
  pip.installed:
    - name: {{ pkg }}
{% endfor %}
