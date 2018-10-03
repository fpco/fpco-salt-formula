#!/usr/bin/env bash

salt-call --local state.sls python.pip
salt-call --local state.sls reclass
salt-call --local state.sls reclass.managed_tops
salt-call --local state.highstate
echo "$(vault version)" || true
vault operator init || true
sleep 2
vault status || true

ufw allow 3000
ufw allow 4646
ufw allow 5000
ufw allow 8200
ufw allow 8500
ufw allow 9090
ufw allow 9100
ufw allow 9111
ufw allow 9172

echo "DONE! ssh in and get hacking: vagrant ssh"
