# removes/un-installs the consul-template executable

{%- set version = '0.10.0' %}
{%- set bin_path = '/usr/local/bin/consul-template' %}


uninstall-consul-template-bin:
  file.absent:
    - name: {{ bin_path }}-{{ version }}
    - require:
        - file: uninstall-consul-template-symlink


uninstall-consul-template-symlink:
  file.absent:
    - name: {{ bin_path }}
