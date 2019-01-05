# docker registry runs on localhost
{%- set service_ip = '127.0.0.1' %}

include:
  - consul.reload

docker-registry-check:
  file.managed:
    - name: /home/consul/conf.d/docker_registry_check.json
    - user: consul
    - group: consul
    - mode: 640
    - contents: |
        {
          "check": {
            "name": "Docker Registry (localhost)",
            "http": "http://{{ service_ip }}:5000",
            "timeout": "10s",
            "interval": "30s"
          }
        }
    # reload consul config after this check.json is in place
    - require_in:
        - cmd: consul-service-check-reload
