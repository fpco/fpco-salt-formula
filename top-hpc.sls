base:
  '*':
    - ufw.install
    - ufw.default_deny
    - ufw.allow_ssh
    - python
    - salt.minion.base

  'master':
    - salt.master

  'compute0':
    - hpc.example-war.master

  'compute[1-5]':
    - hpc.example-war.slave
