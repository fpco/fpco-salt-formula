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


consul-conf-d:
  file.directory:
    - name: {{ home }}/conf.d
    - user: {{ user }}
    - group: {{ user }}
    - mode: 750
    - require:
        - user: consul-user
        - file: consul-user

