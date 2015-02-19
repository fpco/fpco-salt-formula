{%- set log_path = '/var/log/stackage-nightly.log' %}
{%- set docker_run = 'docker run  -it --rm -v $(pwd):/stackage -w /stackage' %}
{%- set image = 'docker.fpcomplete.com/fpco/stackage:latest' %}
{%- set cmd = '/bin/bash -c "cabal update && stackage nightly --skip-upload"' %}
{%- set build = 'nightly' %}
{%- set user = 'stackage' %}

include:
  - stackage.server.builds


stackage-nightly:
  cron.present:
    - name: '{{ docker_run }} {{ image }} {{ cmd }} >> {{ log_path }} 2>&1'
    - identifier: run-stackage-nightly-build
    - user: {{ user }}
    - minute: '0'
    - hour: '0' 
    - require:
        - file: stackage-nightly
        - docker: stackage-image
        - user: stackage
  file.managed:
    - name: {{ log_path }}
    - user: {{ user }}
    - group: root
    - mode: 640
    - source: False
    - replace: False
    - require:
        - user: stackage
