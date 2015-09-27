# ensure the s3-static-registry service is stopped, and remove
# the associated upstart config
{%- set cname = 'docker-registry' %}

docker-registry-proxy-upstart-absent:
  service.dead:
    - name: {{ cname }}
  file.absent:
    - name: /etc/init/{{ cname }}.conf
    - require:
        - service: docker-registry-proxy-upstart-absent
