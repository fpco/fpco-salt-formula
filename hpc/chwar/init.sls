{%- set image_name = salt['pillar.get']('hpc:chwar:image', 'docker.fpcomplete.com/chwar') %}
{%- set image_tag = salt['pillar.get']('hpc:chwar:tag', 'latest') %}
{%- set hpc_port = salt['pillar.get']('hpc:chwar:port', 9999) %}

include:
    - docker.install

hpc-chwar-runtime-image:
  docker.pulled:
    - name: {{ image_name }}
    - tag: {{ image_tag }}
    - require:
        - service: docker

hpc-chwar-open-firewall:
  file.managed:
    - name: /etc/ufw/applications.d/hpc-chwar.conf
    - user: root
    - group: root
    - mode: 640
    - contents: |
        [hpc-chwar]
        title=hpc-chwar
        description=hpc-chwar demo
        ports={{ hpc_port }}/udp
  cmd.wait:
    - name: ufw allow hpc-chwar
    - watch:
        - file: hpc-chwar-open-firewall
