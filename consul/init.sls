# this ought to be renamed to consul.install, but that change ought to come later
# install and setup consul
# download to master, from https://dl.bintray.com/mitchellh/consul/0.4.1_linux_amd64.zip
# unzip and drop into /srv/salt/consul/files/
# this has no assurance on the version installed.

{%- set home = '/home/consul' %}
{%- set user = 'consul' %}
{%- set bin_root = '/usr/local/bin/' %}
{%- set consul_bin = bin_root ~ 'consul' %}
{%- set version = '0.6.3' %}
{%- set install_path = bin_root ~ 'consul-' ~ version %}
{%- set base_url = 'https://releases.hashicorp.com/consul/' ~ version %}
{%- set release_archive = 'consul_' ~ version ~ '_linux_amd64.zip' %}
{%- set release_url = base_url ~ '/' ~ release_archive %}
{%- set checksum = 'fcf96d2955f45b8acba019b8f9b49ce95cea0c66cca8417ddcafe72890974d130c97367a616e234661c85307afbb636887c75a1756edd7952dbf4c1094abf84d' %}

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
        {% set whitelist = ['/usr/sbin/service', '/usr/bin/salt-call',
                            '/usr/bin/docker', '/usr/local/bin/nomad'] %}
        Cmnd_Alias  AGENT_CMD = {% for bin in whitelist %}{{ bin }}, {% endfor %}
        # the consul user can run the list of approved commands on any host,
        # no password is required
        consul ALL = NOPASSWD: AGENT_CMD
