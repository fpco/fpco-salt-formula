{#- this is for reclass nodes/$host.yml #}
{%- set classes = salt['pillar.get']('reclass:localhost:classes', []) %}
{#- this is for reclass nodes/$host.yml #}
{%- set parameters = salt['pillar.get']('reclass:localhost:parameters', {}) %}
{#- filesystem paths for reclass #}
{#- improve this, too brittle of a base path #}
{%- set default_base_path = '/srv/salt-git/fpco-salt-formula' %}
{%- set base_path = salt['pillar.get']('reclass:paths:base', default_base_path) %}
{%- set default_classes_path = base_path ~ '/reclass/classes' %}
{%- set classes_path = salt['pillar.get']('reclass:paths:classes', default_classes_path) %}
{%- set default_nodes_path = base_path ~ '/reclass/nodes' %}
{%- set nodes_path = salt['pillar.get']('reclass:paths:nodes', default_nodes_path) %}
{%- set default_tops_path = base_path ~ '/top.sls' %}
{%- set tops_path = salt['pillar.get']('reclass:paths:tops', default_tops_path) %}

# this symlink will let reclass function from the shell, outside salt, because
# reclass will see /etc/reclass/nodes even though it is /srv/salt/fpco-salt-formula/reclass/nodes
# this is to keep reclass happy
reclass-base_dir:
  file.symlink:
    # note the lack of a trailing slash on the symlink name is intentional
    - name: /etc/reclass
    # point the symlink at salt's file_roots, this ought to be dynamic (looked up)
    - target: {{ base_path }}


# to be super-explicit, we have reclass create a config for itself. this lets us
# more easily run reclass from the shell, and otherwise separate from salt.
reclass-reclass_config:
  file.managed:
    - name: {{ base_path }}/reclass-config.yml
    - mkdirs: True
    - contents: |
        storage_type: yaml_fs
        pretty_print: True
        output: yaml
        inventory_base_uri: /etc/reclass
        nodes_uri: {{ nodes_path }}
        classes_uri: {{ classes_path }}
    - require:
        - file: reclass-base_dir


# this is the core link between reclass and salt, where to find the inventory
# and instructions to use ext_pillar.
# we'll keep it really simple for now, as the details here could get really
# complicated. funny enough, this is easier to sort out once reclass is in use.
reclass-salt_config:
  file.managed:
    - name: /etc/salt/minion.d/reclass
    - contents: |
        reclass: &reclass
          # the only currently supported
          storage_type: yaml_fs
          # reclass will expect to find a classes and nodes directory at this path
          inventory_base_uri: {{ base_path }}
          classes_uri: {{ classes_path }}
          nodes_uri: {{ nodes_path }}

        # at the moment, master_tops is not available to the salt-minion :*
        #master_tops:
        #  reclass: *reclass

        ext_pillar:
          - reclass: *reclass
    - require:
        - file: reclass-reclass_config


# reclass associates classes with a node through a .yml associated with the host
# define a node map for localhost, but do it dynamically, based on a key from pillar
reclass-nodes:
  file.managed:
    - name: {{ nodes_path }}/{{ salt['grains.get']('id') }}.yml
    - contents: |
        classes:
          - base{% if classes %}{% for class in classes %}
          - {{ class }}
          {% endfor %}{% endif %}
        {%- if parameters %}
        parameters: {% for k, v  in parameters.items() %}
          {{ k }}: {{ v }}
          {% endfor %}
        {% endif %}
    - require:
        - file: reclass-salt_config
