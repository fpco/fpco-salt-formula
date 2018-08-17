#!/usr/bin/env bash

set -uv

echo "Execute formulas consul.service and nomad.service"
salt-call --local state.sls consul.service,nomad.service test=True

sudo consul version
sudo consul members
sudo consul kv get -recurse
nomad version
nomad status
nomad agent-info
nomad server members
nomad node status
