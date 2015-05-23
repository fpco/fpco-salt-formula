# install fpbuild on a host

{%- set deb_url = salt['pillar.get']('fpbuild:url', 'http://download.fpcomplete.com/dev-tools/fpbuild/fpbuild_current_amd64.deb') %}
{%- set checksum = salt['pillar.get']('fpbuild:checksum', '6300f589ccbaad526400f10f87c11e9c030bda4709100f2a7a3b602d40c4c4e7af67247309a83dd7ad54359747cb578e4b46aea1684a8740e0f05b696f5362ee') %}

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
  cmd.run:
    - name: 'dpkg --install /tmp/fpbuild_current_amd64.deb'
    - require:
        - file: fpbuild


fpbuild-version:
  cmd.run:
    - name: 'fpbuild --version'
    - require:
        - pkg: fpbuild-deps
        - cmd: fpbuild
        - file: fpbuild


fpbuild-remove-dpkg:
  file.absent:
    - name: /tmp/fpbuild_current_amd64.deb
    - require:
        - cmd: fpbuild
        - cmd: fpbuild-version
