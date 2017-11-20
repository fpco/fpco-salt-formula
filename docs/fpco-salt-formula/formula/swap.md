## `swap`

Create and enable a swap file. This formula creates and executes (then removes)
a shell script with the following:

```
#!/bin/sh
dd if=/dev/zero of=/var/xGB.swap bs=1M count=(x * 1024)
chmod 600 /var/xGB.swap
mkswap /var/xGB.swap
swapon /var/xGB.swap
echo "/var/xGB.swap none swap sw 0 0" >> /etc/fstab
```

Where `x` is pulled from the optional pillar key `size`, which defaults to `1`.

The intention is to apply this formula on its own (not as part of `top.sls` or
similar). For example:

```
salt-call --local state.sls swap pillar='{"size": "5"}'
```
