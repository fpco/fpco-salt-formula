# this top.sls defines a map for all hosts (*) to default formula
base:
  '*':
    - ufw.install
    - ufw.default_deny
    - ufw.allow_ssh
    - python
    - salt.minion.base
    - ufw.enable
