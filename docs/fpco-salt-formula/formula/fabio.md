### `fabio`

The formula creates a nomad job spec at `/root/fabio.job` and then uses the
`cmd.run` salt state to call `nomad run /root/fabio.job` and submit that job
for execution on the nomad cluster. This formula is for dev and testing
purposes - it is not intended as a method for production use.
