virtualbox:
  pkgrepo.managed:
    - humanname: VirtualBox PPA
    - name: deb http://download.virtualbox.org/virtualbox/debian precise contrib
    - dist: precise
    - file: /etc/apt/sources.list.d/virtualbox.list
    - keyid: 98AB5139
    - keyserver: keyserver.ubuntu.com
    - key_url: https://www.virtualbox.org/download/oracle_vbox.asc
  pkg.installed:
    - name: virtualbox-4.3
    - require:
      - pkgrepo: virtualbox
  service.running:
    - name: vboxdrv
    - require:
        - pkg: virtualbox
        - pkg: virtualbox-deps

virtualbox-deps:
  pkg.installed:
    - pkgs:
        - dkms
