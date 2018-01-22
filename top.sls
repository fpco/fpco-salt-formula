# this top.sls defines a map for all hosts (*) to default formula
base:
  '*':
#   - openssh
#   - openssh.config
    - apps.common
    - aws.cli.install
    - python.pip
    - ufw.default_deny
    - ufw.allow_ssh
    - ufw.enable
    - docker
    - dnsmasq
    - consul.install
    - consul.dnsmasq
#   - consul.ext_pillar
    - consul.template-tool
    - consul.tools
    - nomad.install
    - nomad.config
    - sysdig
    - stack.ppa
    - stack.docker_cleanup
    - salt.minion.install
    - salt.minion
#   - salt.minion.consul
#   - salt.file_roots.consul-template
    - docker.install-from-image
#   - prometheus.node-exporter
#   - users.consul-template
    - vault.install
    - git.repos
    - ntp
    - rkt.install
