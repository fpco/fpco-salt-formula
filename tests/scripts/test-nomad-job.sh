#!/usr/bin/env bash

set -ux

# Fix error nomad can resolve nomad.service.consul domain
ip=`ifconfig enp0s3 | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p'`

echo "Run example (hello world) job"
nomad run /vagrant/tests/scripts/test-nomad.nomad

echo "Wait until the job starts (might take a moment to download the docker image)"
ops http poll http://$ip:8080 -r 90

echo "Example job status"
nomad status example

echo "Curl to check that nomad job is up"
stdbuf -oL curl -v $ip:8080
