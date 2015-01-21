{%- set image_name = salt['pillar.get']('hpc:docker_image', 'docker.fpcomplete.com/hpc:test') %}
{%- set master_ip = salt['pillar.get']('hpc:master_ip', '10.200.10.120') %}
{%- set hpc_port = salt['pillar.get']('hpc:port', 9909) %}
{%- set hpc_bin = salt['pillar.get']('hpc:bin', '/usr/local/bin/hpc-example-war') %}

#include:
#  - hpc.example-war

example-war-slave-container:
# docker.running:
#   - name: example-war-slave
#   - image: example-war-runtime-image
#   - command: /usr/local/bin/hpc-example-war slave {{ master_ip }} {{ hpc_port }}
  cmd.run:
    - name: docker run -d {{ image_name }} {{ hpc_bin }} slave {{ master_ip }} {{ hpc_port }}
#   - require:
#       - cmd: hpc-open-firewall
#   - watch:
#       - cmd: runtime-image-to-import
#       - docker: runtime-image-to-import

