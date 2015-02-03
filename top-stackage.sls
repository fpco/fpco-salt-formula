base:
  'web*':
    - salt.minion.base
    - stackage.server.runtime_deps
    - stackage.server

  'build0':
        - stackage.server.cabal-loader

  'master':
    - salt.master
    - salt.minion.base
#   - jenkins
#   - stackage.server.rds
