{# the intention with this formula, is to run this on the master, not the web node #}
{%- set dbname = salt['pillar.get']('stackage:db:name', 'stackage_server_beta') %}
{%- set user = salt['pillar.get']('stackage:db:user', 'stackage_server_beta') %}
{%- set pass = salt['pillar.get']('stackage:db:pass', 'stackage_server_beta') %}
{%- set host = salt['pillar.get']('stackage:db:host', 'localhost') %}

{%- set db_user = salt['pillar.get']('db_super:user', 'super') %}
{%- set db_pass = salt['pillar.get']('db_super:pass', 'FILL-ME-IN') %}

stackage-server-db:
  postgres_database.present:
    - name: {{ dbname }}
    - owner: {{ user }}
    # connection info to create this resource
    - db_user: {{ db_user }}
    - db_password: {{ db_pass }}
    - db_host: {{ host }}
    - require:
        - postgres_user: stackage-server-db
  postgres_user.present:
    - name: {{ user }}
    - password: {{ pass }}
    - refresh_password: True
    - createuser: False
    # connection info to create this resource
    - db_user: {{ db_user }}
    - db_password: {{ db_pass }}
    - db_host: {{ host }}
