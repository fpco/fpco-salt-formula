{%- set image_name = salt['pillar.get']('hpc:exwar:image', 'docker.fpcomplete.com/exwar') %}
{%- set image_tag = salt['pillar.get']('hpc:exwar:tag', 'latest') %}
{%- set master_ip = salt['pillar.get']('hpc:exwar:master_ip', '10.200.10.120') %}
{%- set hpc_port = salt['pillar.get']('hpc:exwar:port', 9909) %}
{%- set hpc_bin = salt['pillar.get']('hpc:exwar:bin', '/usr/local/bin/hpc-example-war') %}

example-war-slave-container:
  docker.running:
    - name: example-war-slave
    - image: {{ image_name }}:{{ image_tag }}
    - detach: True
    - command: {{ hpc_bin }} slave {{ master_ip }} {{ hpc_port }}
