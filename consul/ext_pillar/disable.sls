{%- for m in ['minion', 'master'] %}
salt-consul-ext-pillar-config-{{ m }}:
  file.absent:
    - name: /etc/salt/{{ m }}.d/consul.conf
{% endfor %}
