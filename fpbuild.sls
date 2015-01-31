# install fpbuild on a host

{%- set deb_url = salt['pillar.get']('fpbuild:url', 'http://download.fpcomplete.com/dev-tools/fpbuild/fpbuild_current_amd64.deb') %}
{%- set checksum = salt['pillar.get']('fpbuild:checksum', '64096bbd8cd3d9c28a544ae15a7fbfb563bc4fc057afa2cb3589fe57039e926946b922c6e6a09c1a6808b08f8dfb2e59ce1da4e032a3e3df6f73ebad8b69df49') %}

fpbuild-deps:
  pkg.latest:
    - pkgs:
       - libgmp10

fpbuild:
  file.managed:
    - name: /tmp/fpbuild_current_amd64.deb
    - user: root
    - group: root
    - mode: 400
    - source: {{ deb_url }}
    - source_hash: sha512={{ checksum }}
  pkg.installed:
    - name: fpbuild
    - sources:
        - fpbuild: /tmp/fpbuild_current_amd64.deb
    - watch:
        - file: fpbuild
