glances:
  user.absent:
    - name: glances
  cmd.run:
    - name: ufw delete allow glances
  file.absent:
    - name: /etc/ufw/applications.d/glances
    - require:
        - cmd: glances

{% set pip_packages = ['glances', 'bottle', 'zeroconf'] %}
{% for pkg in pip_packages %}
glances-pip-{{ pkg }}-absent:
  pip.removed:
    - name: {{ pkg }}
{% endfor %}
