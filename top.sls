# this top.sls defines a map for all hosts (*) to default formula
base:
  '*':
    - ntp
    - openssh
    - openssh.config
    - apps.common
    - aws.cli.install
    - python.pip
    - ufw.default_deny
    - ufw.allow_ssh
    - ufw.enable
    - docker
    - dnsmasq
    - consul
    - consul.dnsmasq
    - consul.ext_pillar
    - consul.template-tool
    - consul.tools
    - nomad.install
    - nomad.config
    - newrelic
    - sysdig
    - stack.ppa
    - stack.docker_cleanup
    - salt.minion
    - salt.minion.consul
    - salt.file_roots.consul-template
    - users.consul-template
    - docker.install-from-image
