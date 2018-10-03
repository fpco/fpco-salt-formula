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
  node_class: leader
  server:
    count: 1

consul:
  client_token: "b684a56c-cf86-443b-a48f-52056f21986f"
  leader_count: 1
  master_token: "b684a56c-cf86-443b-a48f-52056f21986f"
  secret_key: "5BqoSqOrQwUuS4QywjePNg=="

vault:
  consul:
    token: b684a56c-cf86-443b-a48f-52056f21986f
    service_tags: "fpco,haskell,rust,elixir"
  disable_tls: True
  scheme: http
