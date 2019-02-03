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
    - docker.install
    - dnsmasq
    - sysdig
    - ntp
    - consul.install
    - vault.install
    - nomad.install
