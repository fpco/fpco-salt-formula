#!/usr/bin/env bash

# Set another path since this path is being shared for all vms
bootstrap_pillar_file="/vagrant/tests/multi/leader/srv/pillar/bootstrap.sls"
leader_id=${LEADER_ID}
echo $leader_id

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
  consul:
    token: "b684a56c-cf86-443b-a48f-52056f21986f"
  datacenter: vagrant
  node_class: leader
  server:
    count: ${leader_id}

consul:
  client_token: "b684a56c-cf86-443b-a48f-52056f21986f"
  leader_count: ${leader_id}
  master_token: "b684a56c-cf86-443b-a48f-52056f21986f"
  secret_key: "5BqoSqOrQwUuS4QywjePNg=="

vault:
  consul:
    token: b684a56c-cf86-443b-a48f-52056f21986f
    service_tags: "fpco,haskell,rust,elixir"
  disable_tls: True
  scheme: http
EOT
echo "role: leaders" > /etc/salt/grains

# Install nomad as Leader
salt-call --local state.sls nomad.install --log-level=debug
salt-call --local state.sls nomad.service.client-server --log-level=debug

