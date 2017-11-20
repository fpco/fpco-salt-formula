## Sysdig

The `sysdig` formula installs the incredible [sysdig](http://www.sysdig.org/)
system intropection utility. Sysdig has a dependency on the linux headers for
the running kernel, so this formula first uses `uname -r` to lookup the active
kernel version, and then installs the `linux-headers-{{ version }}` package from
apt with the `pkg.installed` salt state.

The formula then uses the `pkgrepo.managed` salt state to setup the Sysdig apt
repo with a GPG key imported from `salt://sysdig/files/DRAIOS-GPG-KEY.public`
(that file is tracked in the git repo, and is only sourced from upstream when
there has been a change that has been reviewed and approved). The `sysdig`
package is then installed from apt with the `pkg.installed` salt state.
