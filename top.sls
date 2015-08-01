# this top.sls defines a map for all hosts (*) to default formula
base:
  '*':
    - common
    - ufw.default_deny
    - ufw.allow_ssh
    - python.pip
    - consul.template-tool.install
    - stack.docker_cleanup
    - salt.minion.base
    - dnsmasq.install
    - consul.agent
    - stack.ppa
    - docker
    - zsh
