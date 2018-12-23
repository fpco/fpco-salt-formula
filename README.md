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

## Get the VM running and provisioned

### `vagrant up`

It'll take a while to run, about 15 minutes on an older desktop.

When it's ready, ssh in with `vagrant ssh` and then `sudo su -l` to switch to
the root user.

### Hashistack test

After finish setup the virtual machine and setup the formulas vagrant executes 
scripts that test Consul and Nomad, making sure that these are up and processing requests.

To execute the just the provision steps in the Vagranfile:
```
vagrant provision
```

## Vault

### Initialize and Unseal Vault

Check status:
```
root@ubuntu-xenial:~# vault status
Error checking seal status: Error making API request.

URL: GET http://10.0.2.15:8200/v1/sys/seal-status
Code: 400. Errors:

* server is not yet initialized
```

Initialize:
```
root@ubuntu-xenial:~# vault operator init
Unseal Key 1: ....
Unseal Key 2: ....
Unseal Key 3: ....
Unseal Key 4: ....
Unseal Key 5: ....

Initial Root Token: c25....

Vault initialized with 5 key shares and a key threshold of 3. Please securely
distribute the key shares printed above. When the Vault is re-sealed,
restarted, or stopped, you must supply at least 3 of these keys to unseal it
before it can start servicing requests.

Vault does not store the generated master key. Without at least 3 key to
reconstruct the master key, Vault will remain permanently sealed!

It is possible to generate new unseal keys, provided you have a quorum of
existing unseal keys shares. See "vault operator rekey" for more information.
```

Unseal, times 3:
```root@ubuntu-xenial:~# vault unseal
WARNING! The "vault unseal" command is deprecated. Please use "vault operator
unseal" instead. This command will be removed in Vault 0.11 (or later).

Unseal Key (will be hidden):
Key                Value
---                -----
Seal Type          shamir
Sealed             true
Total Shares       5
Threshold          3
Unseal Progress    1/3
Unseal Nonce       533969ba-89aa-a883-b2f6-ec9594c8ef52
Version            0.10.3
HA Enabled         true
root@ubuntu-xenial:~# vault unseal
WARNING! The "vault unseal" command is deprecated. Please use "vault operator
unseal" instead. This command will be removed in Vault 0.11 (or later).

Unseal Key (will be hidden):
Key                Value
---                -----
Seal Type          shamir
Sealed             true
Total Shares       5
Threshold          3
Unseal Progress    2/3
Unseal Nonce       533969ba-89aa-a883-b2f6-ec9594c8ef52
Version            0.10.3
HA Enabled         true
root@ubuntu-xenial:~# vault unseal
root@ubuntu-xenial:~# vault unseal
WARNING! The "vault unseal" command is deprecated. Please use "vault operator
unseal" instead. This command will be removed in Vault 0.11 (or later).

Unseal Key (will be hidden):
Key                    Value
---                    -----
Seal Type              shamir
Sealed                 false
Total Shares           5
Threshold              3
Version                0.10.3
Cluster Name           vault-cluster-9a2b698e
Cluster ID             3634a7c4-912c-1510-2f29-424091906628
HA Enabled             true
HA Cluster             n/a
HA Mode                standby
Active Node Address    <none>
```

Check status again:
```
root@ubuntu-xenial:~# vault status
Key             Value
---             -----
Seal Type       shamir
Sealed          false
Total Shares    5
Threshold       3
Version         0.10.3
Cluster Name    vault-cluster-9a2b698e
Cluster ID      3634a7c4-912c-1510-2f29-424091906628
HA Enabled      true
HA Cluster      https://10.0.2.15:8201
HA Mode         active
```

login w/ Root Token, from `vault init`:
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


## Multi-host mode

The multihost mode adds a second vm so we can run the hashistack with separate hosts for the two roles:
- Leader
- Worker

The Leader role configures all hashistack as server role and the worker as client role.

```
ᐅ VAGRANT_CWD=./tests/multi vagrant up
```

Unfortunally vagrant doesn't have the flag to pass the vagrantfile as an argument.

