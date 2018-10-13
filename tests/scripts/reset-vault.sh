#!/usr/bin/env bash

set -ux

vault status
service vault stop
consul kv delete -recurse vault
service vault start
vault status
