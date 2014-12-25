docker-dependencies:
  pkg.installed:
    - pkgs:
        - apt-transport-https
        - python-apt
        - iptables
        - ca-certificates
        - lxc
        - python-pip
  pip.installed:
     - name:  docker-py
     - require:
        - pkg: docker-dependencies
        - module: salt-module-refresh

salt-module-refresh:
  module.wait:
    - name: saltutil.refresh_modules
    - watch:
        - pkg: docker-dependencies
        - pkg: docker

docker:
  # the pkgrepo state does not seem to be working 100%, what gives?
  pkgrepo.managed:
    - name: 'deb http://get.docker.com/ubuntu docker main'
    - humanname: 'Docker Apt Repo'
    - file: '/etc/apt/sources.list.d/docker.list'
    - key_url: salt://docker/files/ppa.pgp
    - keyserver: keyserver.ubuntu.com
  pkg.latest:
    - name: lxc-docker
    - require:
        - pkgrepo: docker
        - pkg: docker-dependencies
    - refresh: True
  service.running:
    - enable: True
    - require:
        - pkg: docker


