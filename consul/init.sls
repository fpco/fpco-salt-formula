# this ought to be renamed to consul.install, but that change ought to come later
# install and setup consul
# download to master, from https://dl.bintray.com/mitchellh/consul/0.4.1_linux_amd64.zip
# unzip and drop into /srv/salt/consul/files/
# this has no assurance on the version installed.

{%- set home = '/home/consul' %}
{%- set user = 'consul' %}
{%- set bin_root = '/usr/local/bin/' %}
{%- set consul_bin = bin_root + 'consul' %}
{%- set version = '0.5.2' %}
{%- set install_path = bin_root + 'consul-' + version %}
{%- set release_url = 'https://dl.bintray.com/mitchellh/consul/' + version + '_linux_amd64.zip' %}
{%- set checksum = '7bab204e9891d81a19422e70e20bbb527b7bb0b14c406f77ca38ca8dc11249fe5e45075e31a8eaed4bfce03f4af524b2603f4dcfe4c8b6ab0dfe367a5605553b' %}

include:
  - consul.python
  - consul.user
  - apps.unzip


consul-archive:
  archive.extracted:
    - name: {{ install_path }}
    - source: {{ release_url }}
    - source_hash: sha512={{ checksum }}
    - if_missing: {{ install_path }}/consul
    - archive_format: zip
    - require:
        - pkg: unzip
  file.directory:
    - name: {{ install_path }}
    - user: root
    - group: consul
    - file_mode: 750
    - dir_mode: 750
    - makedirs: True
    - recurse:
        - user
        - group
        - mode
    - require:
        - archive: consul-archive


consul-bin:
  file.symlink:
    - name: {{ consul_bin }}
    - target: {{ install_path }}/consul
    - require:
        - file: consul-archive


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
        Cmnd_Alias  AGENT_CMD = /usr/sbin/service
        # the consul user can run the list of approved commands on any host,
        # no password is required
        consul ALL = NOPASSWD: AGENT_CMD
