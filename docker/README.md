## Docker Formula

This module includes formula to install, configure, and use various tools in
the Docker ecosystem.

### `docker`

By default, `docker.init` will simply apply `docker.install` and `docker.compose`
to install both docker's engine and compose.


### `docker.install`

* Installs docker-engine dependencies
* Configures the Docker/Dotcloud apt repo
* Installs the docker-engine (via Docker's apt repo)
* Installs the docker-py python module (to be available for salt)
* Configures the docker service for either AUFS or devicemapper
* Ensures the service is running

Includes/depends on the `python.pip` formula (to install docker-py). Installing
docker-py ought to be done separately, but this has not yet been updated.

Accepts the following Pillar keys:

* `docker:aufs`: boolean, defaults to `True` to enable AUFS
* `docker:aufs_tools`: package name, aufs tools, currently defaults to
   linux-image-extra-$linux_version
* `docker:default_opts`: passed on to `DOCKER_OPTS` in `/etc/default/docker`,
   defaults to null/empty string.
* `docker:version`: version of docker-engine to install, defaults to `1.7.1`


### `docker.compose`

Installs `docker-compose` directly from github.com/dotcloud/docker repo releases,
and into `/usr/local/bin/docker-compose`.

Accepts the following Pillar keys:

* `docker-compose:version`: version to install, defaults to `1.2.0`
* `docker-compose:checksum`: checksum of the file downloaded from github.com,
   defaults to the checksum for `1.2.0`.


### `docker.registry.proxy`

Runs a proxy to a docker registry, intended to be based on rdr2tls.

Accepts the following Pillar keys:

* `rproxy:image`: docker image to use, defaults to `fpco/rdr2tls`
* `rproxy:tag`: tag for the docker image to pillar/run, defaults to `latest`
* `rproxy:port`: port to run the proxy on, defaults to `5000`
* `rproxy:bucket`: S3 bucket name to point the proxy at
* `rproxy:s3_baseurl`: Base URL to S3, defaults to `s3.amazonaws.com`

When running, the proxy will listen on port `8080`. This formula uses the
upstart config template for running docker containers as a service.


### `docker.registry.proxy.absent`

Used to remove an existing registry installed/running on a host by stopping the
service and removing the upstart config.


### `docker.registry.s3-static-registry`

Runs a docker registry, in the form of an S3-static registry. Possibly to be
deprecated.

Accepts the following Pillar keys:

* `s3-static-registry:name`: Name of the registry, defaults to `s3-static-docker`
* `s3-static-registry:img`: docker image to use, defaults to
  `docker.fpcomplete.com/fpco/static-docker-registry`
* `s3-static-registry:tag`: docker tag for the image to pull/run, defaults to
  `latest`
* `s3-static-registry:ip`: Host IP the registry will listen on, defaults to
  `127.0.0.1`
* `s3-static-registry:port`: Host port the registry will listen on, defaults to
  `5000`
* `s3-static-registry:s3_bucket`: name of the S3 bucket to point the registry at,
  defaults to `s3-static-docker`
* `s3-static-registry:aws_access_key`: Access key at AWS
* `s3-static-registry:aws_secret_key`: Secret key at AWS


### `docker.registry.s3-static-registry.absent`

Used to remove an existing registry installed/running on a host by stopping the
service and removing the upstart config.

Accepts the following Pillar keys:

* `s3-static-registry:name`: Name of the registry to remove, defaults to `s3-static-docker`


### Using the `upstart-tpl-container-as-a-service.sls` Jinja template

A common use case is to run a particular docker image as a container, and for
that container to be available as another system service, just like all other
services.

Regardless of systemd/upstart/runit/etc, this workflow needs to be implemented
carefully: running a docker image as a container instance does not work like a
service in the usual sense:

* before we start the service, we must pull the image currently specified;
* before we create the container instance, we must ensure we remove any
  existing container with our `container_name`;
* before we remove the existing container, we must stop a running container;
* stopping and running the container may fail, and we need to persist thru those
  possible failures;
* finally, we can create the container instance with our docker args, image, tag
  command, and container name;
* the above is pre-start, so now when the service starts, it has already started,
  and we use `exec` to run `docker logs` on that running container.. this ensures
  upstart sees the full log output from the docker container;
* when we go to stop the service, we need to stop the container, and then remove
  it.


The jinja template implements this workflow in a simple way, giving the formula
developer a simplified API that is clear and consistent. Specifically, the developer
can provide the following context dictionary when using the template:

* `env_vars`: key/value dictionary of environment variables, optional
* `img`: the name of the docker image to pull/run, required
* `tag`: the tag of the docker image to pull/run, required
* `container_name`: the name of the container/service instance, required
* `docker_args`: list of command line args to pass to docker, optional. Provide
  in the form:
    ```
    - '--publish 127.0.0.1:{{ port }}:8080'
    ```

* `cmd`: command to run in the docker container, optional
* `desc`: description, for upstart, helpful for admins, required
* `author`: author, for upstart, helpful for admins, required


Upstart `respawn` is enabled, but not much else is done to ensure the service
and container stay running, and/or restart on their own when something fails.

In practice, an example looks like:

```
{%- set image = salt['pillar.get']('hpc_manager:image', 'fpco/hpc-manager-ui') %}
{%- set tag = salt['pillar.get']('hpc_manager:tag', 'latest') %}
{%- set port = salt['pillar.get']('hpc_manager:port', '3000') %}
{%- set approot = salt['pillar.get']('hpc_manager:approot', 'localhost:3000') %}
{%- set redis_host = salt['pillar.get']('hpc_manager:redis_host', 'localhost') %}
{%- set prefix = salt['pillar.get']('hpc_manager:redis_prefix', False) %}
{%- set cname = 'hpc-manager' %}

hpc-manager-docker-ui:
  file.managed:
    - name: /etc/init/{{ cname }}.conf
    - user: root
    - group: root
    - mode: 644
    - source: salt://docker/files/upstart-tpl-container-as-a-service.sls
    - template: jinja
    - context:
        desc: hpc manager ui
        author: the-ops-ninjas@fpcomplete.com
        # the name of the container instance
        container_name: {{ cname }}
        # the Docker image to use
        img: {{ image }}
        # the image tag to reference
        tag: {{ tag }}
        # ip/port mapping
        docker_args:
          - '--publish 127.0.0.1:{{ port }}:3000'
          - '--workdir=/usr/local/lib/hpc-manager/'
          - '-e HPC_REDIS_HOST:{{ redis_host }}'
          {% if prefix %}- '-e HPC_REDIS_PREFIX:{{ prefix }}'{%- endif %}
          {% if approot %}- '-e APPROOT:{{ approot }}'{%- endif %}
        cmd: hpc-manager
  service.running:
    - name: {{ cname }}
    - enable: True
    - watch:
        - file: hpc-manager-docker-ui
```
