{%- set log_path = '/var/log/cabal.log' %}
{%- set loader_bin = '/usr/local/bin/cabal-loader-stackage' %}
{%- set env = 'Staging' %}
{%- set user = 'stackage' %}

include:
  - stackage.server.runtime_deps
  - stackage.server.config

cabal-loader-stackage:
  file.managed:
    - name: /usr/local/bin/cabal-loader-stackage
    - mode: 755
    - user: root
    - group: root
    - source: salt://stackage/server/files/cabal-loader-stackage

  cron.present:
    - name: '{{ loader_bin }} {{ env }} >> {{ log_path }} 2>&1'
    - identifier: run-cabal-loader-stackage
    - user: {{ user }}
    - minute: 30
    - hour: '*' 
    - require:
        - file: cabal-loader-stackage
        - file: cabal-loader-log

cabal-loader-log:
  file.managed:
    - name: {{ log_path }}
    - user: {{ user }}
    - group: root
    - mode: 640
    - source: False
    - replace: False
    - require:
        - user: stackage
