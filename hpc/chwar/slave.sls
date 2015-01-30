{%- set image_name = salt['pillar.get']('hpc:chwar:image', 'docker.fpcomplete.com/chwar') %}
{%- set image_tag = salt['pillar.get']('hpc:chwar:tag', 'latest') %}
{%- set master_ip =  salt['pillar.get']('hpc:chwar:master_ip', '10.10.10.10') %}
{%- set hpc_port = salt['pillar.get']('hpc:chwar:port', 9999) %}
{%- set hpc_bin = salt['pillar.get']('hpc:chwar:bin', '/usr/local/bin/chwar') %}
#salt['grains.get']('ip4_interfaces:eth0')

chwar-slave-container:
  docker.running:
    - name: chwar-slave
    - image: {{ image_name }}:{{ image_tag }}
    - detach: True
    - command: {{ hpc_bin }} slave {{ master_ip }} {{ hpc_port }}
