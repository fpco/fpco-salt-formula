# installs consulkv util from .tar.gz archive (release on github). Example:
# https://github.com/vsco/consulkv/releases/download/v0.4.0/consulkv_v0.4.0_linux_amd64.tar.gz
#
{%- set version = '0.1.0' %}
{%- set base_url = 'https://github.com/spiritloose/consulkv/releases/download' %}
{%- set release_archive = version ~ '/consulkv_' ~ version ~ '_linux_amd64.tar.gz' %}
{%- set release_url = base_url ~ '/v' ~ release_archive %}
{%- set bin_path = '/usr/local/bin/consulkv' %}
{%- set checksum = '8094a3ecf4497120e4611cf8174beb27397201d57930e7c916f2b707cc5f1ef8743681e2e453f8ebcfadda17fed791f94a632cb115579515593b706f24cadf7d' %}


# unpack the release archive from github/etc
consulkv-archive:
  archive.extracted:
    - name: {{ bin_path }}-{{ version }}
    - source: {{ release_url }}
    - source_hash: sha512={{ checksum }}
    - if_missing: {{ bin_path }}-{{ version }}/consulkv
    - archive_format: tar
    - tar_options: 'zvp --strip-components=1'
  file.directory:
    - name: {{ bin_path }}-{{ version }}
    - user: root
    - group: root
    - file_mode: 755
    - dir_mode: 755
    - makedirs: True
    - recurse:
        - user
        - group
        - mode
    - require:
        - archive: consulkv-archive

# create a symlink to the version of the binary that is active
consulkv-active-bin:
  file.symlink:
    - name: {{ bin_path }}
    - target: {{ bin_path }}-{{ version }}/consulkv
    - require:
        - file: consulkv-archive


consulkv-bin:
  # this is just a permissions check for the binary
  file.managed:
    - name: {{ bin_path }}
    - replace: False
    - mode: 755
    - user: root
    - group: root
    - require:
        - file: consulkv-active-bin
  # this confirms our success
  cmd.run:
    - name: 'consulkv --version || true'
    - require:
        - file: consulkv-bin


consulkv-py-helper-script:
  # this script is helpful when combined with the git-file-monitor and
  # consulkv to auto-load arbitrary text/config into consul's KV
  file.managed:
    - name: /usr/local/bin/consulkv-helper.py
    - user: root
    - group: root
    - mode: 755
    - contents: |
        #!/usr/bin/python
        # helper script to use with consulkv and git-file-monitor
        # put simply, this script accepts the full path to the file the user wishes
        # to load into consul with `consulkv put`, and the full path to the git
        # repo that file is located in. The difference between these two paths is
        # the path to the key to put into consul.
        #
        # use: consulkv-helper.py /path/to/repo/path/to/file.ext /path/to/repo
        import sys, os
        file_path = sys.argv[1]
        repo_root = sys.argv[2]
        path_diff = os.path.relpath(os.path.splitext(file_path)[0], repo_root)
        print path_diff
