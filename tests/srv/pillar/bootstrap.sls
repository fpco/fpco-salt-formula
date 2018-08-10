reclass:
  paths:
    base: /vagrant
  localhost:
    # list of classes to associate with this node
    classes:
      - vagrant
      - hashistack-single-node
    # these "parameters" are provided to the node and override defaults
    # inherited from the params defined in other "upstream" classes.
    parameters:
      foo: bar

nomad:
  foo: bar
consul:
  # use `python -c "import uuid; print(uuid.uuid4())"` to generate some of these to pick from
  master_token: "b684a56c-cf86-443b-a48f-52056f21986f"
  client_token: "b684a56c-cf86-443b-a48f-52056f21986f"
  # use `consul keygen` to generate some of these to pick from
  secret_key: "5BqoSqOrQwUuS4QywjePNg=="
      
vault:
  consul:
    token: b684a56c-cf86-443b-a48f-52056f21986f
