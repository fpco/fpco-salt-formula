# ensure the s3-static-registry service is stopped, and remove
# the associated upstart config
{%- set registry_name = salt['pillar.get']('s3-static-registry:name', 's3-static-docker') %}

s3-static-registry-upstart-absent:
  service.dead:
    - name: {{ registry_name }}-registry
  file.absent:
    - name: /etc/init/{{ registry_name }}-registry.conf
    - require:
        - service: s3-static-registry-upstart-absent

