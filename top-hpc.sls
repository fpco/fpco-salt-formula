base:
  '*':
    - ufw.install
    - ufw.default_deny
    - ufw.allow_ssh
    - python
    - salt.minion.base

  'master':
    - salt.master

  'compute*':
    - hpc.example-war
    - hpc.chwar


  'compute0':
        - hpc.chwar.master

  'compute[1-4]':
        - hpc.chwar.slave


  'compute5':
        - hpc.example-war.master

  'compute[6-9]':
        - hpc.example-war.slave

