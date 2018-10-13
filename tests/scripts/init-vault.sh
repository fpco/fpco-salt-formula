#!/usr/bin/env bash

set -ux

vault status
vault operator init -format=json > /vagrant/vault-unseal.json
