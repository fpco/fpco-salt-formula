# configure nomad to use TLS certs for proper encryption and authentication

{%- from "macros.sls" import mkdir with context %}

# this "empty" config will ensure TLS is on by default, if broken, which is
# better than  disabled by default (that is "by default when applying this formula")
{%- set empty_tls_config = {'http': 'true', 'rpc': 'true'} %}
{%- set tls = salt['pillar.get']('nomad:tls', empty_tls_config) %}

{{ mkdir('nomad_tls', '/etc/nomad/tls', 'nomad', 'root') }}

nomad-conf-tls:
  file.managed:
    - name: /etc/nomad/conf.d/tls.hcl
    - user: nomad
    - group: root
    - mode: 640
    - contents: |
        tls {
          {%- for k,v in tls.items() %}
          {{ k }} = "{{ v }}"
          {%- endfor %}
        }
    - require:
        - file: mkdir-nomad_tls
