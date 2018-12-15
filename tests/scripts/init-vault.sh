#!/usr/bin/env bash

set -ux

vault status
vault operator init -format=json > /vagrant/vault-unseal.json

echo "VAULT_TOKEN=$(cat /vagrant/vault-unseal.json | jl '_.root_token')" >> /etc/environment
