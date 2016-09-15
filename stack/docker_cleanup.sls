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
            {% if unknown is defined %}--unknown-images={{ unknown }} \{%- endif %}
            {% if known is defined %}--known-images={{ known }} \{%- endif %}
            {% if dangling is defined %}--dangling-images={{ dangling }} \{%- endif %}
            {% if stopped is defined %}--stopped-containers={{ stopped }} \{%- endif %}
            --no-running-containers
            --immediate

  cron.present:
    - name: {{ cleanup_script }}
    - identifier: stack-docker-cleanup
    - user: root
    - hour: '{{ hour }}'
    - minute: '{{ minute }}'
    - require:
        - file: stack-cron-docker-cleanup

