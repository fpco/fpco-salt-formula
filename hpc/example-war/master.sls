{%- set hpc_port = salt['pillar.get']('hpc:port', 9909) %}
{%- set image_name = salt['pillar.get']('hpc:docker_image', 'docker.fpcomplete.com/hpc:test') %}
{%- set hpc_bin = salt['pillar.get']('hpc:bin', '/usr/local/bin/hpc-example-war') %}
{%- set slave_count = 0 %}

#include:
#  - hpc.example-war

example-war-master-container:
# docker.running:
#   - name: example-war-master
#   - image: example-war-runtime-image
#   - command: /usr/local/bin/hpc-example-war master 1 {{ hpc_port }}
  cmd.run:
    - name: docker run -d {{ image_name }} {{ hpc_bin }} master {{ slave_count }} {{ hpc_port }}
#   - require:
#       - cmd: hpc-open-firewall
#   - watch:
#       - cmd: runtime-image-to-import
#       - docker: runtime-image-to-import

