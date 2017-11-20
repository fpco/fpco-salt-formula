### `golang`

Install the golang tools and compiler:

* Download and unpack ("install") the golang release specified, into
  `/usr/local/go`.
* Setup the `$GOPATH` and `$GOROOT` environment variables for all users on the
  host by managing the file `/etc/profile.d/golang.sh`.
* Create symlinks for the various go executables, `go`, `godoc`, and `gofmt`.

At the moment, the version and checksum (for the release tarball) is hardcoded
in the formula. This will change in a future release of the formula.
