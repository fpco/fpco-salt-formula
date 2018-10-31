reclass:
  paths:
    base: /vagrant
  localhost:
    classes:
      - hashistack-install
      - hashistack
      - nomad-enable-raw-exec
    # these "parameters" are provided to the node and override defaults
    # inherited from the params defined in other "upstream" classes.
    parameters:
      network_interface: enp0s3

nomad:
  client:
    enabled: True
  datacenter: vagrant
  net_if: enp0s3
  server:
    count: 1

consul:
  client_token: "b684a56c-cf86-443b-a48f-52056f21986f"
  secret_key: "5BqoSqOrQwUuS4QywjePNg=="

vault:
  consul:
    token: b684a56c-cf86-443b-a48f-52056f21986f
    service_tags: "fpco,haskell,rust,elixir"
  net_if: enp0s3
