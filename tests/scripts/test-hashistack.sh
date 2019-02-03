#!/usr/bin/env bash

set -uv

echo "running basic sanity checks against salt-formula"
salt-call --local state.highstate test=True

echo "running basic sanity checks against consul and nomad"

sudo consul version
sudo consul members
sudo consul kv get -recurse -keys
nomad version
nomad status
nomad agent-info
nomad server members
nomad node status
vault version
vault status
