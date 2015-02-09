base:
  'consul*':
    - salt.minion.base
    - consul.leader

  'web*':
    - salt.minion.base
    - consul.agent
    - consul.services.stackage-server
    - stackage.server.runtime_deps
    - stackage.server

  'build0':
    - consul.agent
    - stackage.server.cabal-loader

  'build1':
    - consul.agent
    - stackage.server.builds.nightly

  'master':
    - salt.master
    - salt.minion.base
    - consul.webui
    - consul.services.salt-master
#   - jenkins
#   - stackage.server.rds
