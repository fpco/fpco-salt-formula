# this formula will "enable" Consul as an "external pillar provider"
# in the salt-minion and salt-master configurations

{%- set ext_mod_path = '/srv/salt-ext' %}
{%- set ext_ip = salt['grains.get']('ip4_interfaces')['eth0'][0] %}
{%- set consul_port = '8500' %}

{#- use external/private IP when running server mode #}
{%- if salt['pillar.get']('consul:leader_count', False) %}
  {%- set consul_ip = ext_ip %}
{%- else %}
  {%- set consul_ip = '127.0.0.1' %}
{%- endif %}

# write the config snippets for salt
{%- for m in ['minion', 'master'] %}
salt-consul-ext-pillar-config-{{ m }}:
  file.managed:
    - name: /etc/salt/{{ m }}.d/consul.conf
    - user: root
    - group: root
    - mode: 640
    - contents: |
        extension_modules: {{ ext_mod_path }}

        consul_config:
          consul.host: {{ consul_ip }}
          consul.port: {{ consul_port }}

        ext_pillar:
          - consul: consul_config root=salt/shared
          - consul: consul_config root=salt/roles/%(role)s
{% endfor %}

