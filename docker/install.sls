# ensure docker and its dependencies are installed, through apt and pip, and
# that we have then reloaded salt's modules

{%- set opts = salt['pillar.get']('docker:default_opts', '') %}
{%- set lsb = salt['grains.get']('lsb_distrib_codename') %}
{%- set default_docker_version = '5:19.03.1~3-0~ubuntu-bionic' %}
{%- set docker_version = salt['pillar.get']('docker:version', default_docker_version) %}
{% set docker_pkg_name = 'docker-ce' %}

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
        - cmd: pip
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
    - name: 'deb [arch=amd64] https://download.docker.com/linux/ubuntu {{ lsb }} stable'
    - humanname: 'Docker Apt Repo'
    - file: '/etc/apt/sources.list.d/docker.list'
    - key_url: salt://docker/files/ppa.pgp
  pkg.installed:
    - name: {{ docker_pkg_name }}
    - version: {{ docker_version }}
    # run apt-get update before installing
    - refresh: True
    # Pin/hold the package to prevent unwanted upgrades of the package
    - hold: True
    - require:
        - pkgrepo: docker
        - pkg: docker-dependencies
  service.running:
    - enable: True
    - watch:
        - pkg: docker
        - file: docker
    - require:
        - module: docker-refresh_modules
  file.managed:
    - name: /etc/default/docker
    - user: root
    - group: root
    - mode: 640
    - contents: |
        DOCKER_OPTS="{{ opts }}"
