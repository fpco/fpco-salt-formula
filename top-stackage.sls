base:
  '*':
    - salt.minion.base
    - rsyslog.common

  'consul*':
    - consul.leader

  'web*':
    - consul.agent
    - consul.services.stackage-server
    - stackage.server.runtime_deps
    - stackage.server
    - rsyslog.stackage.server

  'build0':
    - consul.agent
    - stackage.server.cabal-loader
    - rsyslog.stackage.cabal-loader

  'build1':
    - consul.agent
    - stackage.server.builds.nightly
    - rsyslog.stackage.nightly-build

  'master':
    - salt.master
    - consul.webui
    - consul.services.consul-webui
    - consul.services.salt-master
    - consul.services.ssh
    - rsyslog.salt-master
#   - jenkins
#   - stackage.server.rds
