#!/usr/bin/env bash

set -ux

. /etc/environment

#VAULT_TOKEN=$(cat /vagrant/vault-unseal.json | jl '_.root_token' | tr -d \")
# this token should match what is in nomad:vault:token key in pillar.
# specifically, tests/srv/pillar/bootstrap.sls, and as a result of
# applying the formula, also /etc/nomad/config.hcl in the VM
CLIENT_TOKEN="5205a4cf-344b-2198-684a-cf8620564844"
vault token create -policy root -orphan -period 72h -id ${CLIENT_TOKEN}
