{%- set pkg_list = salt['pillar.get']('base_pkg', []) %}

{%- if pkg_list %}
base-pkg:
  pkg.installed:
    - pkgs: {%- for pkg in pkg_list %}
        - {{ pkg }}
{%- endfor %}

{%- endif %}
