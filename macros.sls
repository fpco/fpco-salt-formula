{%- macro mkdir(name, path, user, group) %}
mkdir-{{ name }}:
  file.directory:
    - name: {{ path }}
    - user: {{ user }}
    - group: {{ group }}
    - mode: 750
    - makedirs: True
{% endmacro %}


