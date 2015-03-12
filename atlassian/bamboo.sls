{%- set user = 'bamboo' %}
{%- set home = '/home/' + user %}
{%- set app = 'atlassian-bamboo' %}
{%- set version = '5.7.2' %}
{%- set installer_file = app + '-' + version + '.tar.gz' %}
{%- set installer_base_url = 'http://www.atlassian.com/software/bamboo/downloads/binary' %}
{%- set installer_url = installer_base_url + '/' + installer_file %}
{%- set installer_checksum = '8529ca5426a838a1deddecd9ca2868cfcae2217f99853a28023791b5b72e3d6eccf1b0bf61a7af6bcfc5f7e7cd3dbbdbc490869a547454cc25e59491b6bf44c8' %}
{%- set base_path = '/opt' %}
{%- set app_path = base_path + '/' + app + '-' + version %}


include:
  - java


bamboo-user:
  user.present:
    - name: {{ user }}
    - system: True
    - gid_from_name: True
  file.directory:
    - name: {{ home }}
    - user: {{ user }}
    - group: {{ user }}
    - mode: 750
    - require:
        - user: {{ user }}

bamboo-app:
  archive.extracted:
    - name: {{ base_path }}
    - source: {{ installer_url }}
    - source_hash: sha512={{ installer_checksum }}
    - if_missing: {{ app_path }}/bin/
    - archive_format: tar
    - tar_options: z
    - archive_user: {{ user }}
  file.symlink:
    - name: {{ base_path }}/bamboo
    - target: {{ app_path }}
    - require:
        - archive: bamboo-app


bamboo-service:
  file.managed:
    - name: /etc/init.d/bamboo
    - source: salt://atlassian/files/bamboo/init.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 755
    - context:
        # leave this as 'bamboo'
        app: bamboo
        app_path: {{ app_path }}
        user: {{ user }}
        user_home: {{ home }}
    - require:
        - user: bamboo-user
        - file: bamboo-app
  service.running:
    - name: bamboo
    - enable: True
    - require:
        - pkg: openjdk
    - watch:
        - file: bamboo-service
        - file: bamboo-app
        - archive: bamboo-app
        - file: bamboo-config


bamboo-config:
  file.managed:
    - name: {{ app_path }}/atlassian-bamboo/WEB-INF/classes/bamboo-init.properties
    - template: jinja
    - user: bamboo
    - group: bamboo
    - mode: 640
    - contents: |
        bamboo.home={{ home }}
    - require:
        - file: bamboo-app
        - file: bamboo-user
        - user: bamboo-user
