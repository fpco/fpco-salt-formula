## Generic App Installers

Intro


### `apps.common`

The `apps.common` formula simply includes other app installers:

* `apps.zsh`
* `apps.jq`
* `apps.ops`
* `apps.htop`
* `apps.unzip`
* `apps.emacs`


### `apps.deb-s3`

Installs the [deb-s3](https://github.com/krobertson/deb-s3) ruby gem using the
`gem.installed` salt state.


Includes:

* `ruby`


### `apps.emacs`

Installs emacs, version `24.5`, by downloading the `.tar.gz` and building the
application from source (using `configure && make && make install`)


### `apps.fpm`

Installs the [fpm](https://github.com/jordansissel/fpm) ruby gem using the
`gem.installed` salt state.


### `apps.htop`

Installs `htop` from apt using the `pkg.latest` salt state.


### `apps.jq`

By default, this formula simply includes the `apps.jq.release` formula.


#### `apps.jq.release`

Installs version `1.5` of the [jq](https://github.com/stedolan/jq) executable,
directly from Github releases. A symlink is setup at `/usr/local/bin/jq` to
allow multiple versions to coexist alongside one another.


#### `apps.jq.apt`

Installs `jq` from apt using the `pkg-latest` salt state, and runs
`jq --version` with `cmd.run` to confirm the version installed.


### `apps.mercurial`

Installs `mercurial` from apt using the `pkg.latest` salt state.


### `apps.mosh`

Installs `mosh` from apt using the `pkg.latest` salt state, and runs
`ufw allow 60001` with the `cmd.run` state.

Note that there is an `apps.mosh.absent` formula to remove the package and
delete the firewall rule in UFW.


### `apps.ops`

Downloads and installs the [ops](https://github.com/fpco/ops) executable into
`/usr/local/bin/`. The tool is not in an archive, so there is nothing to unpack.
Note that multiple versions of the tool can be installed without removing or
stepping on one another - a symlink is used to link `/usr/local/bin/ops` to the
primary version. There is a map of official releases and their checksums, and
version `0.1.2` is installed by default, so `state.sls apps.ops` will install
without any required pillar or other input. At this time, the formula only
supports installing the executable from `https://download.fpcomplete.com/ops/`.

Pillar keys available:
* `ops:version` - version to install, included as part of the filename, optional
* `ops:checksum` - sha512 checksum for the file to be downloaded, optional


### `apps.unzip`

Installs `unzip` from apt using the `pkg.installed` salt state. Note that
`pkg.latest` is _not_ used so we can avoid running `apt-get update` when it is
not desired.


### `apps.zsh`

Installs `zsh` from apt using the `pkg.latest` salt state.

