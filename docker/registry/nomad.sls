{%- from "consul/template-tool/nomad_macro.sls" import render_job with context %}

{%- set dc = salt['pillar.get']('nomad:datacenter', 'dc') %}
{%- set region = salt['pillar.get']('nomad:region', 'us-west-1') %}

{#- variables to pass to the macro when rendering the salt states #}
{%- set service_name = "docker-registry" %}
{%- set cmd = "salt-call --local state.sls users" %}
{%- set tpl = "salt://docker/registry/nomad.tpl" %}
{%- set context = { 'datacenter': dc, 'region': region} %}

{#- call the macro to render the salt states for this monitor #}
{{ render_job(service_name, tpl, context) }}
