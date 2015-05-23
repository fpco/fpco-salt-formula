# install fpbuild on a host

{%- set deb_url = salt['pillar.get']('fpbuild:url', 'http://download.fpcomplete.com/dev-tools/fpbuild/fpbuild_current_amd64.deb') %}
{%- set checksum = salt['pillar.get']('fpbuild:checksum', 'fde4331b4d84c6bb331665c3c1b565d32c4a174667ce26f8d8ebbcbae6c16d8312b868a8e616007e873613b69de7d49ebb3d14d75b94220cf0fb345fee8b3d2c') %}

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
  cmd.run:
    - name: 'fpbuild --version'
    - require:
        - pkg: fpbuild
        - file: fpbuild
        - pkg: fpbuild-deps
