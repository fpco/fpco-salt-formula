{%- set release_url = 'https://raw.githubusercontent.com/saltstack/salt/develop/salt/pillar/consul_pillar.py' %}
{%- set checksum = '6b23d0e54bcb6773b35633251bb9ecb4f41bae9228e7a980df95e7094ce25efcd1494b151dc9d97d5c4336bb478d53fa895e97c7fe58a2d39c4db9dcc7d42cdb' %}

{%- for m in ['minion', 'master'] %}

salt-{{ m }}-config:
  file.managed:
    - name: /etc/salt/{{ m }}.d/consul_ext_pillar.conf
    - user: root
    - group: root
    - mode: 640
    - contents: |
        extension_modules: /srv/salt/ext
        
        consul_client_config:
            consul.host: 127.0.0.1
            consul.port: 8500
        
        ext_pillar:
            - consul: consul_client_config root=/salt/pillar/
#           - consul: consul_client_config root=/salt/pillar/shared/
#           - consul: consul_client_config root=/salt/pillar/private/%(minion_id)s

{%- endfor %}


salt-ext-path:
  file.directory:
    - name: /srv/salt/ext
    - user: root
    - group: root
    - mode: 750


salt-consul-pillar-module:
  file.managed:
    - name: /srv/salt/ext/consul_pillar.py
    - source: {{ release_url }}
    - source_hash: sha512={{ checksum }}
    - user: root
    - group: root
    - mode: 750


python-consul-client:
  pip.installed:
    - name: python-consul
