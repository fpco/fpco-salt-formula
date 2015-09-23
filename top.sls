# this top.sls defines a map for all hosts (*) to default formula
base:
  '*':
    - common
    - python.pip
    - ufw.default_deny
    - ufw.allow_ssh
    - ufw.enable
    - docker
    - dnsmasq
    - consul
    - consul.dnsmasq
    - consul.template-tool
    - stack.ppa
    - stack.docker_cleanup
    - salt.minion.base
    - salt.master
    - salt.file_roots.consul-template
    - users.consul-template
    - zsh
