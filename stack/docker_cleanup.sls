# periodically, run the following:
#
#    stack docker cleanup \
#        --unknown-images=3 \
#        --known-images=3 \
#        --dangling-images=0 \
#        --stopped-containers=7 \
#        --no-running-containers \
#        --immediate

{%- set unknown = salt['pillar.get']('docker_cleanup:unknown_images', '3') %}
{%- set known = salt['pillar.get']('docker_cleanup:known_images', '3') %}
{%- set dangling = salt['pillar.get']('docker_cleanup:dangling_images', '0') %}
{%- set stopped = salt['pillar.get']('docker_cleanup:stopped_containers', '7') %}
{%- set running = salt['pillar.get']('docker_cleanup:running_containers', False) %}
{%- set hour = salt['pillar.get']('docker_cleanup:hour', '01') %}
{%- set minute = salt['pillar.get']('docker_cleanup:minute', '00') %}
{%- set cleanup_script = '/usr/local/bin/stack-docker-cleanup' %}


stack-cron-docker-cleanup:
  file.managed:
    - name: {{ cleanup_script }}
    - user: root
    - group: root
    - mode: 755
    - contents: |
        #!/bin/sh
        stack docker cleanup \
            {% if unknown %}--unknown-images={{ unknown }}{%- endif %} {% if known %}--known-images={{ known }}{% endif %} {% if dangling %}--dangling-images={{ dangling }} {%- endif %} {% if stopped %}--stopped-containers={{ stopped }}{%- endif %} {% if running %}--running-containers={{ running }}{% else %}--no-running-containers{% endif %} --immediate

  cron.present:
    - name: {{ cleanup_script }}
    - identifier: stack-docker-cleanup
    - user: root
    - hour: '{{ hour }}'
    - minute: '{{ minute }}'
    - require:
        - file: stack-cron-docker-cleanup

