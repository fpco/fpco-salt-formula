## `ruby`

The `ruby` formula installs the `ruby-dev` and `gcc` packages from apt with the
`pkg.installed` salt state. If the `ruby-dev` package changes, the
`saltutil.refresh_modules` salt module is used to ensure salt's gem modules and
states have been refreshed.

The primary purpose of this formula is to ensure other formula can use the
`gem.installed` salt state to install ruby gem packages, and is not yet meant to
provide complete support for the ruby ecosystem.
