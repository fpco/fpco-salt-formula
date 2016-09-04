emacs:
  pkg.installed:
    - pkgs:
#       - build-dep
        - build-essential
        - emacs24
  file.managed:
    - name: /root/emacs.sh
    - user: root
    - mode: 750
    - contents: |
        #!/bin/bash
        cd ~
        mkdir emacs-src && cd emacs-src
        wget http://mirror.team-cymru.org/gnu/emacs/emacs-24.5.tar.gz
        tar xvf emacs-24.5.tar.gz
        cd emacs-24.5
        ./configure
        make
        make install
    - require:
        - pkg: emacs
  cmd.run:
    - name: /root/emacs.sh
    - require:
        - file: emacs
