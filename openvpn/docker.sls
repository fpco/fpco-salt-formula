# Run kylemanna/docker-openvpn Docker image as a service
#
# More details are documented in pillar:
{%- set image = salt['pillar.get']('openvpn:image', 'kylemanna/openvpn') %}
{%- set tag = salt['pillar.get']('openvpn:tag', 'alpine') %}
{%- set port = salt['pillar.get']('openvpn:port', '1194') %}
{%- set ip = salt['grains.get']('ip4_interfaces')['eth0'][0] %}

{%- set cname = 'openvpn' %}

openvpn-upstart:
  file.managed:
    - name: /etc/init/{{ cname }}.conf
    - user: root
    - group: root
    - mode: 644
    - source: salt://docker/files/upstart-tpl-container-as-a-service.sls
    - template: jinja
    - context:
        desc: OpenVPN
        author: the-ops-ninjas@fpcomplete.com
        # the name of the container instance
        container_name: {{ cname }}
        # the Docker image to use
        img: {{ image }}
        # the image tag to reference
        tag: {{ tag }}
        # ip/port mapping
        docker_args:
          - '--publish {{ ip }}:{{ port }}:1194/udp'
          - '--volume /etc/openvpn:/etc/openvpn'
          - '--cap-add=NET_ADMIN'
  service.running:
    - name: openvpn
    - enable: True
    - watch:
        - file: openvpn-upstart
