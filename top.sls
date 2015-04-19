# this top.sls defines a map for all hosts (*) to default formula
base:
  '*':
    - ufw.default_deny
    - ufw.allow_ssh
    - python.pip
    - salt.minion.base
    - consul.agent
