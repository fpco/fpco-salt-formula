{%- set image_name = salt['pillar.get']('hpc:chwar:image', 'docker.fpcomplete.com/chwar') %}
{%- set image_tag = salt['pillar.get']('hpc:chwar:tag', 'latest') %}
{%- set master_ip = salt['grains.get']('ip4_interfaces:eth0') %}
{%- set hpc_port = salt['pillar.get']('hpc:chwar:port', 9999) %}
{%- set hpc_bin = salt['pillar.get']('hpc:chwar:bin', '/usr/local/bin/chwar') %}

chwar-master-container:
  docker.running:
    - name: chwar-master
    - image: {{ image_name }}:{{ image_tag }}
    - detach: True
    - command: {{ hpc_bin }} master {{ master_ip }} {{ hpc_port }}
