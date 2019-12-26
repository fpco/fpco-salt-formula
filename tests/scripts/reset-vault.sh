#!/usr/bin/env bash

set -ux

vault status
service vault stop
consul kv delete -recurse vault
service vault start
sleep 5
vault status
