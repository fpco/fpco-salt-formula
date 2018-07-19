reclass:
  paths:
    base: /vagrant
  localhost:
    classes:
      - vagrant
      - hashistack-single-node
    parameters:
      foo: bar

nomad:
  net_if: enp0s3
vault:
  net_if: enp0s3
