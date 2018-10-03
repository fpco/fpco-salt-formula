#!/usr/bin/env bash

salt-call --local state.sls python.pip
salt-call --local state.sls reclass
salt-call --local state.sls reclass.managed_tops
salt-call --local state.highstate
echo "$(vault version)" || true
vault operator init || true
sleep 2
vault status || true
echo "DONE! ssh in and get hacking: vagrant ssh"
