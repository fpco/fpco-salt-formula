base:
  'web*':
    - salt.minion.base
    - postgres.client
    - stackage.server.runtime_deps
    - stackage.server

  'master':
    - salt.master
    - salt.minion.base
#   - stackage.server.rds
