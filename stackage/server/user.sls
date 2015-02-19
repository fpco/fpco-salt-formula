{%- set app = 'stackage-server' %}
{%- set base_url = salt['pillar.get']('stackage:server:release:base_url', 'SET_URL') %}
{%- set checksum = salt['pillar.get']('stackage:server:release:checksum', 'SET_CHECKSUM') %}
{%- set release = salt['pillar.get']('stackage:server:release:tag', 'SET_RELEASE') %}
{%- set base_path = '/opt' %}
{%- set release_path = base_path + '/' + app + '-' + release %}

stackage:
  user.present:
    - name: stackage
    - system: True
    - gid_from_name: True
  file.symlink:
    - name: /home/stackage
    - target: {{ release_path }}
    - force: True
    - require:
        - archive: stackage-release


stackage-release:
  file.directory:
    - name: {{ release_path }}
    - user: stackage
    - group: stackage
    - require:
        - user: stackage
  archive.extracted:
    - name: {{ release_path }}
    - source: {{ base_url }}/{{ app }}-{{ release }}.keter
    - source_hash: sha512={{ checksum }}
    # .keters are flat, without a containing directory
    - if_missing: {{ release_path }}/dist/
    - archive_format: tar
    - archive_user: stackage
    - tar_options: z
    - require:
        - file: stackage-release
