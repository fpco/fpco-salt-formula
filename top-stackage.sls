base:
  'web*':
    - salt.minion.base
    - stackage.server.runtime_deps
    - stackage.server

  'build0':
        - stackage.server.cabal-loader

  'build1':
        - stackage.server.builds.nightly

  'master':
    - salt.master
    - salt.minion.base
#   - jenkins
#   - stackage.server.rds
