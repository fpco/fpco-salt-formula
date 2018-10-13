#!/usr/bin/env bash

set -u

vault status
for KEY in $(cat /vagrant/vault-unseal.json | jl --lines '_.unseal_keys_b64' | sed 's/"//g' | head -n 3) ; do
  vault operator unseal $KEY
done

