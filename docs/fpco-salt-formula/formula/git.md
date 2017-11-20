## Git

Installs git and uses pillar to manage the repositories checked out on a host.


### `git`

The `git` formula simply includes the `git.latest` formula.


### `git.install`

Installs the `git` package with the `pkg.installed` salt state. Use this if
you want to ensure the git package is installed, and want to ensure that doing
so does not call `apt-get update` unless it is needed.


### `git.latest`

Installs the `git` package with the `pkg.latest` salt state. This will ensure
the latest package is installed at the expense of calling out to
`apt-get update`.


### `git.repos`

This formula primarily does three things:

* Include the `git.install` formula (to ensure the git package is present)
* Create a "home directory" for git repos (using the `src:git:home` pillar key)
* Checkout a specific revision of one or more git repos from the `src:git:repos`
  pillar key.


#### Supported Pillar

| Pillar Key        | Default    | Required |             Notes                  |
| ----------------- | ---------- |:--------:| ---------------------------------- |
| `src:git:home`    | `/usr/src` | N | Root path where git repos are checked out |
| `src:git:user`    | `root`     | N | User to run git management with           |
| `src:git:group`   | `root`     | N | Group to run git management with          |
| `src:git:identity_file` | `root/.ssh/id_rsa` | N | Relevant if using SSH to checkout repos, required if `user` pillar is not default |
| `src:git:repos`   | `{}` | N | No repos are checked out by default, see the dictionary format below |


#### Format for the `src:git:repos` pillar key

```
repos:
  <repo>:
    url: <supported_git_url>
    rev: <git_revision>
```

For example:

```
repos:
  my_repo:
    url: git@github.com:user/my_repo.git
    rev: master
  lts-haskell:
    url: https://github.com/fpco/lts-haskell.git
    rev: release
  another_repo:
    url: git://host.url/another_repo
    rev: 2d2ba1b
```


#### Additional Notes

This formula is very flexible, as it will play nice with existing SSH and git
configurations. For example, it's possible to keep a really simple config when
checking out a repo from a private git server running on a non-default port by
defining a host entry in the SSH client config:

```
Host private-git
    User git
    HostName private.example.com
    Port 2222
```

See the `openssh.config` formula (from `saltstack-formula` repo upstream) to
simplify managing that SSH config with pillar.

With this type of host entry in SSH config, you can then define a repo in
pillar like:

```
repos:
  my_repo:
    url: private-git:foo/my-repo.git
    rev: master
```

This is much nicer than having to figure out the right combination of details
in the url directly.
