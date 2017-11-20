## Hostname Management

The `hostname` formula manages the system hostname with the following actions:

* Manage the contents of the `/etc/hostname` file.
* The hostname can be set by defining the `hostname` pillar key, and defaults to
  Salt's `fqdn` grain.
* Ensure the `hostname` service is running.
* Restarts the `hostname` service if the `/etc/hostname` file changes.
* Runs `saltutil.refresh_modules` to reload Salt's grains if the `hostname`
  service changes state.
