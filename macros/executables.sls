{%- macro install_executable(bin_name, file_url, checksum, version, user='root', group='root', mode='755', install_to='/usr/local/bin') %}

{{ bin_name }}-release:
  file.managed:
    - name: {{ install_to }}/{{ bin_name }}-{{ version }}
    - source: {{ file_url }}
    - source_hash: {{ checksum }}
    - user: {{ user }}
    - group: {{ group }}
    - mode: {{ mode }}

{{ bin_name }}-bin:
  file.symlink:
    - name: {{ install_to }}/{{ bin_name }}
    - target: {{ install_to }}/{{ bin_name }}-{{ version }}
    - require:
        - file: {{ bin_name }}-release
  cmd.run:
    - name: {{ bin_name }} --version
    - require:
        - file: {{ bin_name }}-bin
{%- endmacro %}
