## apps Formula

This module includes formula to install various tools often requested by the
team, or used in an automated system.


### `deb-s3`

* includes `ruby`
* installs the `deb-s3` app as a ruby gem
* requires (applies) the ruby/gem install and salt module refresh before this gem


### `emacs`

* writes out a custom install script for emacs-24.4, then runs that script.
* aims to be an update/improvement over the default package in ubuntu.
* the custom install script could be updated to run latest release, or converted


### `fpm`

* includes `ruby`
* installs the `fpm` app as a ruby gem
* requires (applies) the ruby/gem install and salt module refresh before this gem


### `htop`

* installs the `htop` monitoring app


### `jq.apt`

* installs `jq` from apt


### `jq.release`

* installs `jq` from upstream directly
* uses symlinking to allow multiple executables to co-exist


### `mercurial`

* Installs `mercurial` from apt


### `mosh`

* installs `mosh` from apt
* opens the port `60001`
* has a `mosh.absent` for easy removal


### `unzip`

* installs `unzip` from apt


### `zsh`

* installs `zsh` from apt

