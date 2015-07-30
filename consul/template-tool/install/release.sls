# installs consul-template from .tar.gz archive. Example:
# https://github.com/hashicorp/consul-template/releases/download/v0.10.0/consul-template_0.10.0_linux_amd64.tar.gz
#
{%- set version = '0.10.0' %}
{%- set root = '/root' %}
{%- set install_to = '/usr/local/bin' %}
{%- set bin_path = install_to + '/consul-template' %}
{%- set base_url = 'https://github.com/hashicorp/consul-template/releases/download/' %}
{%- set archive_basename = 'consul-template_' + version + '_linux_amd64' %}
{%- set archive_filename = archive_basename + '.tar.gz' %}
{%- set release_url = base_url + 'v' + version + '/' + archive_filename %}
{%- set checksum = 'c63424413436fbc0d9148ac01ad1e61eef15ed4ae901de7a824435777e0aa79e24c2d77fd29eef3e9b81a0ee11e480934da3ae3c0534377329341dd2dc3f6874' %}

consul-template-path:
  file.directory:
    - name: {{ bin_path }}-{{ version }}
    - user: root
    - group: root
    - mode: 755


consul-template-bin:
  archive.extracted:
    - name: {{ bin_path }}-{{ version }}
    - source: {{ release_url }}
    - source_hash: sha512={{ checksum }}
    - if_missing: {{ bin_path }}-{{ version }}/consul-template
    - archive_format: tar
    - tar_options: 'z --strip-components=1 {{ archive_basename }}/consul-template'
    - require:
        - file: consul-template-path


consul-template:
  file.symlink:
    - name: {{ bin_path }}
    - target: {{ bin_path }}-{{ version }}/consul-template
    - watch:
        - archive: consul-template-bin
    - user: root
    - group: root
    - mode: 755
