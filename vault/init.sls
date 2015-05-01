# install and setup vault
# downloads from https://dl.bintray.com/mitchellh/vault/vault_0.1.0_linux_amd64.zip

{%- set app = 'vault' %}
{%- set user = app %}
{%- set home = '/home/' + user %}
{%- set version = '0.1.0' %}
{%- set base_url = 'https://dl.bintray.com/mitchellh/' + app %}
{%- set release_archive = app + '_' + version + '_linux_amd64.zip' %}
{%- set release_url = base_url + release_archive %}
{%- set bin_path = '/usr/local/bin/' + app %}
{%- set checksum = 'dd3b391e06e12829325395ea1c3e4c17d722520a8fa73668a9f0b8d6b4cc6e20afde31cd2669c8b611773d851d5b530d0eeb870943457b8acffa3510489961f8' %}

{%- set default_data_dir = home + '/data' %}
{%- set c = salt['pillar.get']('vault', {}) %}
{%- set data_dir = c['path'] or default_data_dir %}


include:
  - unzip


vault-bin:
  archive.extracted:
    - name: {{ bin_path }}-{{ version }}
    - source: {{ release_url }}
    - source_hash: sha512={{ checksum }}
    - if_missing: {{ bin_path }}-{{ version }}/vault
    - archive_format: zip
    - require:
        - pkg: unzip
  file.symlink:
    - name: {{ bin_path }}
    - target: {{ bin_path }}-{{ version }}/vault
    - require:
        - archive: vault-bin


vault-user:
  user.present:
    - name: {{ user }}
    - system: True
    - gid_from_name: True
    - home: {{ home }}
    - shell: /usr/sbin/nologin
  file.directory:
    - name: {{ home }}
    - user: {{ user }}
    - group: {{ user }}
    - dir_mode: 750
    - file_mode: 640
    - recurse:
        - user
        - group
        - mode


vault-data-dir:
  file.directory:
    - name: {{ data_dir }}
    - user: {{ user }}
    - group: {{ user }}
    - mode: 750
    - require:
        - user: vault-user
        - file: vault-user


vault-config:
  file.managed:
    - name: {{ home }}/config.json
    - source: salt://vault/files/config.hcl
    - user: {{ user }}
    - group: {{ user }}
    - mode: 640
    - template: jinja
    - defaults:
        backend: {{ c['backend'] }}
        path: {{ data_dir }}
        cert_file: {{ home }}/server.crt
        key_file: {{ home }}/server.key
    - require:
        - user: vault-user
        - file: vault-user


vault-server:
  file.managed:
    - name: /etc/init/vault-server.conf
    - mode: 640
    - user: root
    - group: root
    - source: salt://vault/files/upstart.conf
    - template: jinja
    - defaults:
        home: {{ home }}
        bin_path: {{ bin_path }}
        run_as_user: 'vault'
        opts: ''
  service.running:
    - name: vault-server
    - watch:
        - file: vault-server
        - file: vault-config
        - archive: vault-bin

