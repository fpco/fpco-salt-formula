base:
  'web*':
    - salt.minion.base
    - stackage.server.runtime_deps
    - stackage.server

  'master':
    - salt.master
    - salt.minion.base
#   - stackage.server.rds
