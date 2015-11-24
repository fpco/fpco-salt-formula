{#-
 #  How to use this template?
 #
 #   s3-static-registry:
 #     file.managed:
 #       - name: /etc/init/my-registry.conf
 #       - user: root
 #       - group: root
 #       - mode: 644
 #       - source: salt://docker/files/upstart-tpl-container-as-a-service.sls
 #       - template: jinja
 #       - context:
 #           desc: Warp HTTP Server
 #           author: the-ops-ninjas@fpcomplete.com
 #           # the name of the container instance
 #           container_name: my-warp
 #           # the Docker image to use
 #           img: fpco/wai-crowd
 #           # the image tag to reference
 #           tag: latest
 #           # ip/port mapping
 #           ip: 127.0.0.1
 #           host_port: 8000
 #           container_port: 8000
 #           # application env vars..
 #           env_vars:
 #             S3_BUCKET: my_bucket
 #             AWS_ACCESS_KEY_ID: {{ access_key }}
 #             AWS_SECRET_ACCESS_KEY: {{ secret_key }}
 #           # list of additional/custom docker args to pass in
 #           docker_args:
 #             - '-e SETTINGS_FLAVOR=prod'
 #             - '--entrypoint /usr/local/bin/foo'
 #
 -#}
description "{{ desc }}"
author "{{ author }}"
start on filesystem and started docker
stop on runlevel [!2345]
respawn

{%- if env_vars is defined %}
{%- for var, val in env_vars.items() %}
env {{ var }}={{ val }}
{%- endfor %}
{%- endif %}

pre-start script
    /usr/bin/docker pull {{ img }}:{{ tag }}

    /usr/bin/docker stop {{ container_name }} || true
    /usr/bin/docker rm {{ container_name }} || true
    /usr/bin/docker create \
        --name {{ container_name }} \
        {#- be careful with - around here... #}
        {%- if docker_args is defined %}
        {%- for arg in docker_args %}
        {{ arg | indent(8) }} \
        {%- endfor %}
        {%- endif %}
        {{ img }}:{{ tag }} {% if cmd is defined %} \
        {{ cmd }}{% endif %}
    # we actually start the container here...
    /usr/bin/docker start {{ container_name }}
end script

# tail the logs, this is our 'pseudo-daemon'
exec /usr/bin/docker logs -f -t {{ container_name }}

pre-stop script
    # stop the container before the logs, preferred
    /usr/bin/docker stop {{ container_name }}
end script

# stop: docker logs tail

post-stop script
    # double stop, incase the logs exited before the pre-stop docker stop
    /usr/bin/docker stop {{ container_name }} || true
    # need to rm the container instance here so the next start succeeds
    # note that we'll lose docker entry, rely on upstart to have caught logs..
    /usr/bin/docker rm {{ container_name }} || true
end script

