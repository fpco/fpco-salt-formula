#!/usr/bin/env bash

set -x

# Set another path since this path is being shared for all vms
bootstrap_pillar_file="/vagrant/tests/multi/worker/srv/pillar/bootstrap.sls"
worker_id=${WORKER_ID}
echo $worker_id

cat <<EOT > ${bootstrap_pillar_file}
reclass:
  paths:
    base: /vagrant
  localhost:
    classes:
      - vagrant-multi-node.yml
    # these "parameters" are provided to the node and override defaults
    # inherited from the params defined in other "upstream" classes.
    parameters:
      network_interface: enp0s3

nomad:
  client:
    enabled: True
  server:
    count: ${worker_id}

consul:
  client_token: "b684a56c-cf86-443b-a48f-52056f21986f"
  secret_key: "5BqoSqOrQwUuS4QywjePNg=="

vault:
  consul:
    token: b684a56c-cf86-443b-a48f-52056f21986f
    service_tags: "fpco,haskell,rust,elixir"

EOT

echo "role: worker" > /etc/salt/grains

# Install nomad as Worker
salt-call --local state.sls nomad.install --log-level=debug
salt-call --local state.sls nomad.service.client-server --log-level=debug

