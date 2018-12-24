reclass:
  paths:
    base: /vagrant
  localhost:
    # list of classes to associate with this node
    classes:
      - vagrant-single-node
    # these "parameters" are provided to the node and override defaults
    # inherited from the params defined in other "upstream" classes.
    parameters:
      foo: bar

nomad:
  consul:
    # to use when accessing consul as a client
    token: "b684a56c-cf86-443b-a48f-52056f21986f"
  vault:
    # to use when accessing vault as a client
    # here is a static token
    token: "5205a4cf-344b-2198-684a-cf8620564844"
    create_from_role: nomad-cluster
    # can also retrieve the token dynamically from credstash
    #credstash:
    #  enabled: True
    #  table: vagrant-credstash
    #  aws_region: us-west-2
    #  role: vagrant
    #  token_key_path: vagrant/nomad_vault_token

consul:
  # use `python -c "import uuid; print(uuid.uuid4())"` to generate some of these to pick from
  master_token: "b684a56c-cf86-443b-a48f-52056f21986f"
  client_token: "b684a56c-cf86-443b-a48f-52056f21986f"
  # use `consul keygen` to generate some of these to pick from
  secret_key: "5BqoSqOrQwUuS4QywjePNg=="

vault:
  consul:
    token: b684a56c-cf86-443b-a48f-52056f21986f
    service_tags: "fpco,haskell,rust,elixir"
