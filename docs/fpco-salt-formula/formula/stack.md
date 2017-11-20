## Haskell and Stack

This package contains various formula for installing and using the `stack` build
tool for [Haskell](https://haskell-lang.org/). For more info, see the
[Stack documentation](https://docs.haskellstack.org/en/stable/README/).


### `stack.ci_config`

Adds a `~/.stack/stack.yaml` for the user specified in salt pillar, targeting
the `root` user by default. The contents of the config are:

```yaml
docker:
  auto-pull: true
```

#### Pillar Supported

Within the `stack` pillar, the following keys are supported:

| Pillar Key | Default  | Required |             Notes                    |
| ---------- | -------- |:--------:| ------------------------------------ |
| `home`     | `/root`  | N | Location where to manage the `stack.yaml`   |
| `user`     | `root`   | N | Linux user to target for this config file   |
| `group`    | `root`   | N | Linux group (in setting file mode)          |


### `stack.docker_cleanup`

This formula generates a script in `/usr/local/bin/stack-docker-cleanup` and
a cronjob to run that script every day. The script uses `stack docker cleanup`
to remove (cleanup) Docker's image/container cruft. See that subcommand's
[help documentation](https://docs.haskellstack.org/en/stable/docker_integration/#cleanup-clean-up-old-images-and-containers)
for more information.

For example, by default, the script runs the equivalent of:

```
stack docker cleanup        \
    --unknown-images=3      \
    --known-images=3        \
    --dangling-images=0     \
    --stopped-containers=7  \
    --no-running-containers \
    --immediate
```

The `cron.present` state is used with the `hour` and `minute` parameters to
run this script every day, and sets the `identifier` to `stack-docker-cleanup`.
The cron entry can be seen with `crontab -l | grep stack-docker-cleanup`.


#### Pillar Supported

Within the `docker_cleanup` pillar, the following keys are supported:

| Pillar Key           | Default  | Required |             Notes                    |
| -------------------- | -------- |:--------:| ------------------------------------ |
| `unknown_images`     | `3`      | N | Passed to `--unknown-images`                |
| `known_images`       | `3`      | N | Passed to `--known-images`                  |
| `dangling_images`    | `0`      | N | Passed to `--dangling-images`               |
| `stopped_containers` | `7`      | N | Passed to `--stopped-containers`            |
| `running_containers` | `False`  | N | If set, include the `--running-container` parameter, else use `--no-running-containers` |
| `hour`               | `01`     | N | Hour used in cron spec                      |
| `minute`             | `00`     | N | Minute used in cron spec                    |


### `stack.pkg_deps`

Installs `libtinfo-dev` with the `pkg.installed` salt state.


### `stack.ppa`

Uses the `pkgrepo.managed` salt state to setup the stack PPA with an entry in
`/etc/apt/sources.list.d/fpco.list` for the PPA at
`http://download.fpcomplete.com/ubuntu`, and the using the GPG key from
`http://download.fpcomplete.com/ubuntu/fpco.key`. The `stack` package is then
installed from that PPA using the `pkg.installed` salt state and the `version`
parameter (set via the `stack:version` pillar key).


#### Pillar Supported

Within the `stack` pillar, the following keys are supported:

| Pillar Key | Default          | Required |             Notes               |
| ---------- | ---------------- |:--------:| ------------------------------- |
| `version`  | `'1.5.1-0~' ~ lsb_codename` | N | Sets the `version` for `pkg.installed` |

