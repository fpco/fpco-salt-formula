## Local DNS Cache and Lookups with dnsmasq

[dnsmasq](http://www.thekelleys.org.uk/dnsmasq/doc.html) is used for DNS caching
and to support integrating Consul as a server to lookup any DNS entry ending in
`.consul` (which is configured in the `consul.dnsmasq` formula).


### `dnsmasq`

Simply includes the `dnsmasq.install` and `dnsmasq.service` formula.


### `dnsmasq.install`

Installs the `dnsmasq` package from apt with the `pkg.latest` salt state.


### `dnsmasq.service`

Manages the `/etc/dnsmasq.d/00-localhost` file with the following contents:

```ini
# edits will be lost, contents auto-managed by salt
# only listen on localhost address and interface
interface=lo
listen-address=127.0.0.1
# disable DHCP, this is DNS only
no-dhcp-interface=lo
# bind to the localhost interface, no passive monitor
bind-interfaces
```

Then ensures the `dnsmasq` service is enabled at boot, running now, and reloads
the service if the `/etc/dnsmasq.d/00-localhost` changes.
