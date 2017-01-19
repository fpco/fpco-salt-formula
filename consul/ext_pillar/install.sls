# This formula will ensure the host's salt minion/master have consulkv
# available/configured as a source of external pillar data. Steps:
#  - add a directory for the pillar module
#  - download the consul_pillar.py source from github, put in that directory
#  - configure `extension_modules` to point to that directory
#  - configure ext_pillar and consul for both minion/master
#  - ensure the consul IP is correct
{%- set ext_mod_path = '/srv/salt-ext' %}
{%- set mod_src_url = 'https://raw.githubusercontent.com/saltstack/salt/79d7e7059c133812d9bd5e3fe7a1ce5a97275024/salt/pillar/consul_pillar.py' %}
{%- set mod_src_sha = '2b76d70aec6db8ebb8a4de26c276b1d4da147b8eb30c9abe87790f1b4cf1439779e7f2457fed2c7dcd6381a9b459cfffd9a0a901c2755f4c64b73e9eb0ca53d3' %}

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


