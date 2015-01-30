{%- set image_name = salt['pillar.get']('hpc:exwar:image', 'docker.fpcomplete.com/exwar') %}
{%- set image_tag = salt['pillar.get']('hpc:exwar:tag', 'latest') %}
{%- set hpc_port = salt['pillar.get']('hpc:port', 9909) %}

include:
    - docker.install

hcp-example-war-runtime-image:
  docker.pulled:
    - name: {{ image_name }}
    - tag: {{ image_tag }}
    - require:
        - service: docker

hpc-example-war-open-firewall:
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
        - file: hpc-example-war-open-firewall
