# FPCO Salt Formula

Here you will find recipes for setting up a host system (or environment) in a
particular way. The focus is generally on building, hosting, or supporting one
or more applications and services.


### About the formula

The formula (recipes) express desired states of being for the host system,
declaring the details of the users, packages, files, services, and all other
aspects of the underlying linux system that should be present, absent, running,
or not, enabled or disabled, etc on the host. In particular, the formula here
targets Ubuntu Linux LTS.


### What you will find here

* Salt Formula (`.sls`, `.py`);
* shell scripts (`.sh`), minimal;
* and lots of app/service config files, generally as (jinja)[] templates.

---

## How to Use

More information will come. For the interested, start with `bootstrap.sh` here
in the root of the repository.


## Using the formula with multiple formula repos

This section is out of date, please see the `bootstrap-salt-formula` repo.

It is often sensible to source formula from multiple repos. This repo includes a
method for doing so. Adding the following pillar to a host will setup the host
with the formula repos used in hosts by default:

```
    salt:
      master:
        service:
          status: running
          enabled: True
        file_roots:
          base:
            - /srv/salt/fpco-salt-formula
            - /srv/salt/openssh-formula
            - /srv/salt/fail2ban-formula

    file_roots_bootstrap:
      src:
        fpco-salt-formula:
          url: git@github.com:fpco/fpco-salt-formula.git
          rev: 'develop'
        openssh-formula:
          url: https://github.com/saltstack-formulas/openssh-formula
          rev: '1b74efd2d0'
        fail2ban-formula:
          url: https://github.com/saltstack-formulas/fail2ban-formula
          rev: '105cf31'
```

Then apply the formula to sync file roots and update the salt master config:

    salt 'host' state.sls salt.file_roots.multiple test=True
    salt 'host' state.sls salt.master test=True


Drop the `test=True` to really apply the formula.

---

# Vagrant Test Env

This is primarily used to test the various formula and functions of those systems
configured. Here is how to setup and use Vagrant for testing and R&D.

## Dependencies

You'll need to install Virtualbox and Vagrant for your host OS.

## box, single, multi-host

Rather than have each `vagrant up` or provisioning run go through a whole build,
we can create a vagrant box which is used as a foundation for the `vagrant up` to
build on top of.

The `box` build produces a Vagrant box we can import and use in new vagrant builds
(eg, with `vagrant up`).

The `single` build uses the `foundation` Vagrant box to run the complete hashistack
on a single VM.

The `multi-host` build creates multiple VMs with the `foundation` Vagrant box. ATM
there are two VMs. One is a `worker` and the other a `leader`.


## How to run and use the vagrant env

Here is the short version (skip to next section for more details):

```
make box           # 1) create a vagrant box we can import and use for another build
make import        # 2) import the base box we just built (into vagrant)
make single        # 3) use the base box to build a new host applying the "single" role
make init-vault    # 4) reset and init the Vault, it is sealed (WIP, see scripts instead)
make unseal-vault  # 5) unseal the Vault to start using it (WIP, see scripts instead)
```

Proceed below for the more manual method that is the same as above

## If you want the details

### 1) Create a base box


Build the base box, this will be used by other vagrant builds.

The automated way: `make box`

This shortcut will:
* copy the `Vagrantfile.box` to `Vagrantfile`
* Run the `box` build, with `vagrant up`
  * this might take 10 - 15 minutes on the average workstation
* Package the VM as a `.box` for Vagrant with `vagrant package`

### 2) Import the `.box` so it's available for a `Vagrantfile` to reference

The automated way: `make import`

This shortcut will:
* Use `vagrant box add` to use the `foundation.box` for the `fpco/foundation` box in Vagrant

#### Note..

The `fpco/foundation` in the command above is what we reference in our
`Vagrantfile`, if you change one, change the other.

#### Also Note..

This VM is fine for working with the formula, R&D, debugging, etc. If you would
like to use the running hashistack for some R&D, etc (such as on a metrics or
logging stack, developing solutions around vault, etc), continue on to the next
section. Otherwise, `vagrant ssh` would be next, most likely.


### Singlebox

This build produces a single VM that runs the whole hashistack on one host.

The automated way: `make single`

This shortcut will:
* copy the `Vagrantfile.single` to `Vagrantfile`
* Run the `single` build, with `vagrant up`
  * It'll take a while to run, about 15 minutes on an older desktop.

When it's ready, ssh in with `vagrant ssh` and then `sudo su -l` to switch to
the root user to use it as-is, or proceed to setup Vault as described below.

### Initialize and Unseal Vault (quick)

```
/vagrant/tests/scripts/init-vault.sh
/vagrant/tests/scripts/unseal-vault.sh
```


## Multi-Host

This is not yet functional, but here is how the build is run.

This build produces 2 VMs, one that runs as a leader and the other a worker in
the hashistack.

Use either `make multi` or:

```
ᐅ cp Vagrantfile.multi Vagrantfile
ᐅ vagrant up
```

## `make world`

```
ᐅ vdf && vup && vpo foundation.box && vba --force fpco/foundation foundation.box && cp Vagrantfile.single Vagrantfile && vdf && vup
```

---

## Vault

Be sure to have initialized and unsealed the vault (see section above).

See also the scripts for Vault in `tests/scripts/`.

### Login w/ Root Token

The root token is returned from Vault as part of the vault initialization.
```
root@ubuntu-xenial:~# vault login
Token (will be hidden):
Success! You are now authenticated. The token information displayed below
is already stored in the token helper. You do NOT need to run "vault login"
again. Future Vault requests will automatically use this token.

Key                  Value
---                  -----
token                c25015....
token_accessor       c4c...
token_duration       ∞
token_renewable      false
token_policies       ["root"]
identity_policies    []
policies             ["root"]
```

`vault` is now ready for additional configuration and use.


### Interacting with the Static Secret Store

Write to vault static secret store:

```
root@ubuntu-xenial:~# vault kv put secret/app_password key=laskdjsalkjdsa
Success! Data written to: secret/app_password
```

Retrieve that key:
```
root@ubuntu-xenial:~# vault kv get secret/app_password
=== Data ===
Key    Value
---    -----
key    laskdjsalkjdsa
```

Retrieve _only_ the key field in the secret:

```
root@ubuntu-xenial:~# vault kv get -field=key secret/app_password
laskdjsalkjdsa
```

Use a data file, here is some JSON:

```
root@ubuntu-xenial:~# cat data.json
{
  "app": "dog",
  "region": "us-west-1",
  "password": "foobar"
}
```

Write the secret sourced from this data file:

```
root@ubuntu-xenial:~# vault kv put secret/app_data @data.json
Success! Data written to: secret/app_data
```

Retrieve that secret:

```
root@ubuntu-xenial:~# vault kv get secret/app_data
====== Data ======
Key         Value
---         -----
app         dog
password    foobar
region      us-west-1
```

Retrieve only one field within the secret, at a time:

```
root@ubuntu-xenial:~# vault kv get -field=password secret/app_data
foobar
root@ubuntu-xenial:~# vault kv get -field=region secret/app_data
us-west-1
```

---

## TLS in the Vagrant Test Env 

In order to emulate production deployments as best as possible, some tasks we want 
to perform in our Vagrant environment will require TLS.
We use self-signed certificates with a bootstrapped certificate authority in 
order to achieve this.

### Steps to Create TLS Certificates to use in Vagrant

Make sure you have [cfssl](https://cfssl.org/) installed beforehand on your
local machine.

To generate the CA and TLS files first cd into the `tests/tls` directory on your local
machine.
From within that directory you may need to update the `vars.mk` file with the
correct region.

After this is complete run `make` (or `make -C tests/tls` if you are not in the directory).

This will generate the certificates that you can then use when you provision your
Vagrant box. Currently these certificates will just reside within the `tls` 
directory and not the Vagrant environment itself.

The current approach uses `cfssl` to generate the certs. For more information
regarding that see the 
[Nomad docs](https://www.nomadproject.io/guides/security/securing-nomad.html).
