## `stackage.server` formula

Deploys and configures the `stackage-server` webapp as a service, based on the
`stackage-server.keter`.

### Configuring

Details can be found in `/srv/pillar/stackage/server.sls`.


### Updating a deployment

Upload the new `.keter`:

```
tag=`git rev-parse --short HEAD` scp stackage-server.keter stackage-master:/srv/salt/stackage/server/files/stackage-server-$tag.keter
```

Now we tell salt which release tag it should use. This is controlled via the
`stackage:server:release:tag` key in `/srv/pillar/stackage/server.sls`. Update
this key to match `$tag` from `git rev-parse --short HEAD`.

To deploy to one host, we use a specific _target_ such as `'web0'`:
`salt 'web0' state.sls stackage.server test=True`

By including `test=True`, salt will tell us details about what will happen when
we apply the formula. If you review the output, you ought to see the first few
state entries that confirm the change in the release tag/revision.

Re-run without `test=True` to actually apply the update: `salt 'web0' state.sls stackage.server test=True`.

We can then check `stackage-server` starting up on `web0` by reviewing the log:
`salt 'web0' cmd.run 'tail /var/log/upstart/stackage-server.log'`.

If we need to rollback, we update the tag again in `/srv/pillar/stackage/server.sls`,
and re apply the formula with `salt 'web0' state.sls stackage.server`.

If we like what we see, we can apply to more/all hosts. Modify the target in the
commands used above. `'web*'` and `'web[1-3]'` will both work as expected:

`salt 'web[1-3]' state.sls stackage.server`
