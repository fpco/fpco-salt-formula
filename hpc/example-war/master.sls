{%- set hpc_port = salt['pillar.get']('hpc:exwar:port', 9909) %}
{%- set image_name = salt['pillar.get']('hpc:exwar:image', 'docker.fpcomplete.com/exwar') %}
{%- set image_tag = salt['pillar.get']('hpc:exwar:tag', 'latest') %}
{%- set hpc_bin = salt['pillar.get']('hpc:exwar:bin', '/usr/local/bin/hpc-example-war') %}
{%- set slave_count = 0 %}

example-war-master-container:
  docker.running:
    - name: example-war-master
    - image: {{ image_name }}:{{ image_tag }}
    - detach: True
    - command: {{ hpc_bin }} master {{ slave_count }} {{ hpc_port }}
