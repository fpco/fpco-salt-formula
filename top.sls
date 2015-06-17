# this top.sls defines a map for all hosts (*) to default formula
base:
  '*':
    - common
    - ufw.default_deny
    - ufw.allow_ssh
    - python.pip
    - salt.minion.base
    - consul.agent
    - stack.ppa
    - docker
    - zsh
