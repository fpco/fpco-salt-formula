base-pkg:
  pkg.installed:
    - pkgs: {%- for pkg in salt['pillar.get']('base_pkg') %}
        - {{ pkg }}
{%- endfor %}

