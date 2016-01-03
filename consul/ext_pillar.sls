# This formula will ensure the host's salt minion/master have consulkv
# available/configured as a source of external pillar data. Steps:
#  - add a directory for the pillar module
#  - download the consul_pillar.py source from github, put in that directory
#  - configure `extension_modules` to point to that directory
#  - configure ext_pillar and consul for both minion/master
#  - ensure the consul IP is correct
{%- set ext_mod_path = '/srv/salt-ext' %}
{%- set mod_src_url = 'https://github.com/saltstack/salt/raw/d4f9e2b6ee681c8f8799777c6da108416ccd26b2/salt/pillar/consul_pillar.py' %}
{%- set mod_src_sha = 'ceed5a4b847747cc1b338c55a3c2633f9a55c0b33e67d0fd53a51f14a650f990f0c14b51588f6f50520ade051f7b493aca6543ea9ec432da0b1cd7331cfd8328' %}
{%- set ext_ip = salt['grains.get']('ip4_interfaces')['eth0'][0] %}
{%- set consul_port = '8500' %}

{#- use external/private IP when running server mode #}
{%- if salt['pillar.get']('consul:leader_count', False) %}
  {%- set consul_ip = ext_ip %}
{%- else %}
  {%- set consul_ip = '127.0.0.1' %}
{%- endif %}

# this state is only necessary until salt in ubuntu has consul_pillar.py
salt-ext-modules-path:
  file.directory:
    - name: {{ ext_mod_path }}
    - user: root
    - group: root
    - mode: 750
    - makedirs: True

# this state is only necessary until salt in ubuntu has consul_pillar.py
salt-consul-ext-pillar-source:
  file.managed:
    - name: {{ ext_mod_path }}/pillar/consul_pillar.py
    - source: {{ mod_src_url }}
    - source_hash: sha512={{ mod_src_sha }}
    - makedirs: True
    - user: root
    - group: root
    - mode: 750

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
          - consul: consul_config root=salt/minion/%(minion_id)s
{% endfor %}
