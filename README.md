## FPCO Salt Formula

Here you will find recipes for setting up a host system (or environment) in a
particular way. The focus is generally on building, hosting, or supporting one
or more applications and services.


### About the formula

The formula (recipes) express desired states of being for the host system,
declaring the details of the users, packages, files, services, and all other
aspects of the underlying UNIX system that should be present, absent, running,
or not, enabled or disabled, etc on the host.


### What you will find here

* Salt Formula (`.sls`, `.py`);
* shell scripts (`.sh`), minimal;
* and lots of app/service config files, generally as (jinja)[] templates.


## How to Use

More information will come. For the interested, start with `bootstrap.sh` here
in the root of the repository.


## Heads Up!

These are for development and experimental purposes, and at any given point in
time the source in this repository will likely contain proprietary information.
Efforts will be made to ensure sensitive credentials/etc are not included in the
repository, but this repository *should remain private at all times*.


## Using the formula with multiple formula repos

It is often sensible to source formula from multiple repos. This repo includes a
method for doing so. Adding the following pillar to a host will setup the host
with the formula repos used in hosts by default:

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


Then apply the formula to sync file roots and update the salt master config:

    salt 'host' state.sls salt.file_roots.multiple test=True
    salt 'host' state.sls salt.master test=True


Drop the `test=True` to really apply the formula.
