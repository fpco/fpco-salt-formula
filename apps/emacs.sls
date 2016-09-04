{%- set build_cmd = './configure && make && make install' %}
{%- set build_dir = '/root' %}
{%- set version = '24.5' %}
{%- set checksum = 'fa08dd1f08bf59746e120118cfa0657dec357868570d073d28a173f32df2472be97eece4cb6d8886ef17b5fc12f7f8cc0070cfbc7be5a7089069d01eb5548129' %}

build-emacs:
  pkg.installed:
    - pkgs:
        - libncurses5-dev
        - build-essential
        - emacs24
  archive.extracted:
    - name: {{ build_dir }}
    - source: http://mirror.team-cymru.org/gnu/emacs/emacs-{{ version }}.tar.gz
    - source_hash: sha512={{ checksum }}
    - if_missing: {{ build_dir }}/emacs-{{ version }}/configure
    - archive_format: tar
    - tar_options: 'z'
  cmd.run:
    - name: {{ build_cmd }}
    - cwd: {{ build_dir }}/emacs-{{ version }}
    - unless: 'emacs --version | grep "{{ version }}"'
    - require:
        - archive: build-emacs
        - pkg: build-emacs


emacs-version:
  cmd.run:
    - name: emacs --version
    - require:
        - cmd: build-emacs
