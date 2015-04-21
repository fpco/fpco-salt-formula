# install docker-compose from github

{%- set checksum = 'e25d0f2a63bde97e43973f4e085c089e957a7538fd371b2846ddc308b34f35812aee5c032cd4df63a58a90498e88adfcd00c0985ba41661c607d6ecbd9ff3af7' %}
{%- set version = '1.2.0' %}

compose-executable:
  file.managed:
    - name: /usr/local/bin/docker-compose
    - source: https://github.com/docker/compose/releases/download/{{ version }}/docker-compose-Linux-x86_64
    - source_hash: sha512={{ checksum }}
    - user: root
    - mode: 755
