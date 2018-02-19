base:
  '*':
  - ufw
  - ufw.default_deny
  - ufw.enable
  - ufw.allow_ssh
  - reclass
  - pkg
  - python.pip
  - apps.common
  - aws.cli.install
  - docker
  - dnsmasq
  - sysdig
  - salt.minion.install
  - salt.minion
  - ntp
