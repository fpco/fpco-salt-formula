## Monitoring with Glances

Glances is a simple but powerful monitoring solution for one or more hosts.
It is a cross-platform tool written in python, has an htop-like interface for
the console, includes a web UI, and can track stats over time with exports to
CSV and many other time-series and related monitoring tools.


Links:

* [homepage](https://nicolargo.github.io/glances/)
* [docs](http://glances.readthedocs.io/en/latest/)
* [wiki](https://github.com/nicolargo/glances/wiki)
* [github](https://github.com/nicolargo/glances)


### `glances.install`

This formula is best if you want to install glances on a host directly, without
docker.

* The `pkg.installed` salt state is used to install glances' dependencies,
  `libssl-dev` and `libpython2.7-dev`, from apt.
* The `pip.installed` state is used to install the `glances`, `bottle`, and
  `zeroconf` python packages with pip.
* The `user.present` state is used to add a system user `glances`, with the uid
  `991`, as a member of the `docker` group, and with its shell set to
  `/usr/sbin/nologin`.
* The `file.managed` state is used to create a configuration file for UFW,
  opening port `61209`.
* The `cmd.run` state is used to execute `ufw allow glances` to open that port.


### `glances.service`

Use this formula to run `glances` as a service, via upstart, and using either
docker or the executable installed the host directly.

* The `file.managed` state is used to create and manage an init config for
  upstart. If `docker` is enabled (see pillar below), the upstart template is
  sourced from `docker/files/upstart-tpl-container-as-a-service.sls`, else the
  `upstart/files/generic.conf` template is used.
* The `service.running` state is used to enable and run the `glances` service
  with upstart.
* Note that, when run with docker, the `/var/run/docker.sock` unix socket is
  mounted `ro` as a volume, and the container is run with `--pid=host` (see the
  [docker docs](https://docs.docker.com/engine/reference/run/#pid-settings---pid)
  for more on `--pid`).


#### Supported Pillar

| Pillar Key        | Default | Required |                 Notes                  |
| ----------------- | ------- |:--------:| -------------------------------------- |
| `glances:browser` | `False` | N        | Enables the `--browser` parameter, and sets the container IP to `127.0.0.1`   |
| `glances:agent`   | `True`  | N        | Enables the `--server` parameter, and sets the container IP to `eth0`        |
| `glances:webui`   | `False` | N        | Enables the `--webserver` parameter, sets the container IP to `127.0.0.1`, and opens/maps the host port `61208`   |
| `glances:docker`  | `False` | N        | Runs the `glances` service with docker |
| `glances:opts`    | `''`    | N        | Provide options for `GLANCES_OPTS`     |
