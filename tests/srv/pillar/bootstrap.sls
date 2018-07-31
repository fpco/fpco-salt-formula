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
  net_if: enp0s3
  datacenter: vagrant
  server_count: 1
  bootstrap_expect: 1
  server: True
vault:
  net_if: enp0s3

consul:
  net_if: enp0s3
  # use `python -c "import uuid; print(uuid.uuid4())"` to generate some of these to pick from
  master_token: b684a56c-cf86-443b-a48f-52056f21986f
  client_token: b684a56c-cf86-443b-a48f-52056f21986f
  datacenter: vagrant
  domain: vagrant
  leader_count: 1
  server: True
  # use `consul keygen` to generate some of these to pick from
  secret_key: '5BqoSqOrQwUuS4QywjePNg=='

# this is the name of the network interface used by vbox/vagrant
# note that the specific name of your interface may differ.
network_interface: enp0s3

base_pkg:
  - htop
  - python3
