# install and setup consul
# download to master, from https://dl.bintray.com/mitchellh/consul/0.4.1_linux_amd64.zip
# unzip and drop into /srv/salt/consul/files/
# this has no assurance on the version installed.

{%- set home = '/home/consul' %}
{%- set user = 'consul' %}

include:
  - consul.user


consul-bin:
  file.managed:
    - name: /usr/local/bin/consul
    - source: salt://consul/files/consul
    - user: root
    - group: root
    - mode: 755


consul-config:
  file.managed:
    - name: {{ home }}/config.json
    - source: salt://consul/files/config.json
    - user: {{ user }}
    - group: {{ user }}
    - mode: 640
    - template: jinja
    - defaults:
        dc: us-east-1
        home: {{ home }}
        leaders: []
        server: False
    - require:
        - user: consul-user
        - file: consul-user
