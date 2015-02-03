# ensure docker and its dependencies are installed, through apt and pip, and
# that we have then reloaded salt's modules

include:
  - python.pip

docker-dependencies:
  pkg.installed:
    - pkgs:
        - apt-transport-https
        - python-apt
        - iptables
        - ca-certificates
        - lxc
  pip.installed:
    - name:  docker-py
    - require:
        - pip: pip
        - module: pip-refresh_modules
        - pkg: docker-dependencies

docker-refresh_modules:
  module.wait:
    - name: saltutil.refresh_modules
    - require:
        - pkg: docker-dependencies
        - pip: docker-dependencies
        - pkg: docker
    - watch:
        - pkg: docker-dependencies
        - pip: docker-dependencies
        - pkg: docker

docker:
  group.present:
    - name: docker
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
    - watch:
        - pkg: docker
    - require:
        - module: docker-refresh_modules


