# ensure docker and its dependencies are installed, through apt and pip, and
# that we have then reloaded salt's modules

{%- set aufs = salt['pillar.get']('docker:aufs', True) %}
{%- set linux_version = salt['cmd.run']('uname -r') %}
{%- set default_aufs_tools_pkg = 'linux-image-extra-' ~ linux_version %}
{%- set aufs_tools = salt['pillar.get']('docker:aufs_tools', default_aufs_tools_pkg) %}
{%- set default_opts = salt['pillar.get']('docker:default_opts', '') %}
{%- set dm_opts = '--storage-opt dm.basesize=20G' %}
{%- set docker_version = salt['pillar.get']('docker:version', '1.7.1') %}

{#- this ought to be fixed up, the logic is not clean #}
{%- if aufs %}
{%- set opts = default_opts %}
{%- else %}
{%- set opts = dm_opts %}
{%- endif %}


include:
  - python.pip


{%- if aufs %}
aufs-docker-tools:
  pkg.latest:
    - name: {{ aufs_tools }}
    - require_in:
        - pkg: docker
        - service: docker
{%- endif %}

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
    - name: 'deb http://get.docker.com/ubuntu docker main'
    - humanname: 'Docker Apt Repo'
    - file: '/etc/apt/sources.list.d/docker.list'
    - key_url: salt://docker/files/ppa.pgp
    - keyserver: keyserver.ubuntu.com
  pkg.installed:
    - name: lxc-docker-{{ docker_version }}
    - require:
        - pkgrepo: docker
        - pkg: docker-dependencies
    - refresh: True
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

