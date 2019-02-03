reclass:
  paths:
    base: /vagrant
  localhost:
    # list of classes to associate with this node
    classes:
      - hashistack-install
    # these "parameters" are provided to the node and override defaults
    # inherited from the params defined in other "upstream" classes.
    parameters:
      foo: bar


