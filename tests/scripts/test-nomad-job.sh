#!/usr/bin/env bash


# Fix error nomad can resolve nomad.service.consul domain
ip=`ifconfig enp0s3 | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p'`
grep $ip /etc/hosts || echo "$ip nomad.service.consul" >> /etc/hosts

# Run nomad job
echo "Init example job"
nomad run /vagrant/tests/scripts/test-nomad.nomad
echo "Wait 10s to nomad init the job"
sleep 10

# Check status of the job
echo "Example job status"
nomad status example

# Test nomad job
echo "Curl to check that nomad job is up"
stdbuf -oL curl -v $ip:8080
