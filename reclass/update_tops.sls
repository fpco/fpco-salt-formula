{#- filesystem paths for reclass #}
{%- set default_base_path = '/srv/salt-git/fpco-salt-formula' %}
{%- set base_path = salt['pillar.get']('reclass:paths:base', default_base_path) %}
{%- set default_nodes_path = base_path ~ '/reclass/nodes' %}
{%- set nodes_path = salt['pillar.get']('reclass:paths:nodes', default_nodes_path) %}
{#- the full node uri parameter to pass to reclass #}
{%- set nuri = '--nodes-uri ' + nodes_path + ' ' %}
{%- set default_classes_path = base_path ~ '/reclass/classes' %}
{%- set classes_path = salt['pillar.get']('reclass:paths:classes', default_classes_path) %}
{#- the full class url parameter to pass to reclass #}
{%- set curi = '--classes-uri ' + classes_path + ' ' %}
{%- set default_tops_path = base_path ~ '/top.sls' %}
{%- set tops_path = salt['pillar.get']('reclass:paths:tops', default_tops_path) %}
{#- the complete command to update top.sls with a dump from reclass for this node #}
{%- set update_tops_cmd = 'reclass-salt --top ' + nuri + curi + ' > ' + tops_path %}

include:
  - reclass.base

reclass-update_tops:
  cmd.run:
    - name: {{ update_tops_cmd }}
    - require:
        - file: reclass-nodes
