{%- set grains = salt['pillar.get']('grains', {}) %}

salt-grains-config:
  file.managed:
    - name: /etc/salt/grains
    - user: root
    - group: root
    - mode: 640
    - contents: |{%- for name, value in grains.items() %}
        {{ name }}: {{ value }}
        {% endfor %}
