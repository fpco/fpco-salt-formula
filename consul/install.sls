# this ought to be renamed to consul.install, but that change ought to come later
# install and setup consul
# download to master, from https://dl.bintray.com/mitchellh/consul/0.4.1_linux_amd64.zip
# unzip and drop into /srv/salt/consul/files/
# this has no assurance on the version installed.

{% from "consul/checksum_map.jinja" import consul_checksum_map with context %}
{%- set default_version = '1.3.1' %}
{%- set version = salt['pillar.get']('consul:version', default_version) %}
{%- set default_checksum = consul_checksum_map[version] %}
{%- set checksum = salt['pillar.get']('consul:checksum', default_checksum) %}
{%- set default_base_url = 'https://releases.hashicorp.com' %}
{%- set base_url = salt['pillar.get']('consul:base_url', default_base_url) %}
{%- set app = 'consul' %}
{%- set release_archive = app ~ '_' ~ version ~ '_linux_amd64.zip' %}
{%- set release_url = base_url ~ '/' ~ app ~ '/' ~ version ~ '/' ~ release_archive %}
{%- set bin_path = '/usr/local/bin/' ~ app %}
{%- set home = '/home/' ~ app %}
{%- set user = app %}
{%- set bin_root = '/usr/local/bin/' %}
{%- set consul_bin = bin_root ~ app %}
{%- set install_path = bin_root ~ app ~ '-' ~ version %}

include:
  - consul.user
  - apps.unzip


consul-archive:
  archive.extracted:
    - name: {{ install_path }}
    - source: {{ release_url }}
    - source_hash: sha512={{ checksum }}
    - if_missing: {{ install_path }}/{{ app }}
    - archive_format: zip
    - enforce_toplevel: False
    - require:
        - pkg: unzip
  file.directory:
    - name: {{ install_path }}
    - user: consul
    - group: consul
    - file_mode: 750
    - dir_mode: 750
    - makedirs: True
    - recurse:
        - user
        - group
        - mode
    - require:
        - archive: {{ app }}-archive


consul-bin:
  file.symlink:
    - name: {{ consul_bin }}
    - target: {{ install_path }}/{{ app }}
    - require:
        - file: {{ app }}-archive


consul-conf-d:
  file.directory:
    - name: {{ home }}/conf.d
    - user: {{ user }}
    - group: {{ user }}
    - mode: 750
    - require:
        - user: consul-user
        - file: consul-user

consul-sudoers-conf:
  file.managed:
    - name: /etc/sudoers.d/consul
    - user: root
    - group: root
    - mode: 644
    - contents: |
        # define a command alias for the list of commands the agent can run
        Cmnd_Alias  AGENT_CMD = /usr/sbin/service, /usr/bin/salt-call, /usr/bin/docker
        # the consul user can run the list of approved commands on any host,
        # no password is required
        consul ALL = NOPASSWD: AGENT_CMD
