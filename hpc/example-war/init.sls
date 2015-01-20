{%- set runtime_tarball = '/root/example-war-runtime.tar' %}
{%- set image_tag = 'hpc/example-war:latest' %}
{%- set image_name = salt['pillar.get']('hpc:docker_image', 'docker.fpcomplete.com/hpc:test') %}
{%- set hpc_port = salt['pillar.get']('hpc:port', 9909) %}

include:
    - docker.install

# first attempt..
#runtime-image-to-import:
#  docker.loaded:
#    - name: example-war-runtime
#    - source: salt://hpc/files/hpc-example-war-runtime.tar
#    - require:
#        - service: docker
#        - module: salt-module-refresh

# second attempt..
#runtime-image-to-import:
#  file.managed:
#    - name: /root/example-war-runtime.tar
#    - source: salt://hpc/files/hpc-example-war-runtime.tar
#    - mode: 600
#    - user: root
#    - group: root
#  cmd.run:
#    - name: docker import {{ runtime_tarball }} {{ image_tag }}
#    - unless: 
#    - require:
#        - file: runtime-image-to-import
#        - service: docker
#        - module: salt-module-refresh

runtime-image-to-import:
# third attempt..
# docker.pull:
#   - name: docker.fpcomplete.com/hpc:test
#   - tag: example-war-runtime
# finally.. salt-minion is not loading docker module, currently for unknown reason
  cmd.run:
    - name: docker pull {{ image_name }}
    - require:
        - service: docker

hpc-open-firewall:
  file.managed:
    - name: /etc/ufw/applications.d/hpc-example.conf
    - user: root
    - group: root
    - mode: 640
    - contents: |
        [hpc-example]
        title=hpc-example-war
        description=hpc-example-war demo
        ports={{ hpc_port }}/tcp
  cmd.wait:
    - name: ufw allow hpc-example
    - watch:
        - file: hpc-open-firewall
