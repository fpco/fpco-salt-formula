#!/usr/bin/env bash

# install python and related packages/tools
salt-call --local state.sls python.pip --log-level=debug

# install reclass and run basic setup/config
# this will use bootstrap.sls to setup node/class mapping
salt-call --local state.sls reclass --log-level=debug

# this will use reclass config to control contents of top.sls
# when creating a base box, we aim to install tools, not run them
# the node/class mapping controls this, edit bootstrap pillar to customize
#salt-call --local state.sls reclass.managed_tops --log-level=debug

# using the updated top.sls, run highstate (all formula in node's top.sls)
salt-call --local state.highstate --log-level=debug
 
# confirm versions of tools installed
salt-call --version
reclass --version
pip --version
aws version
consul version
nomad version
vault version
ops --help
jl --help
jq --version

# clean up before exiting (we will create a box from this vm)
apt-get clean

# this lets us easily set the hostname/minion id
rm -f /etc/salt/minion_id

echo "\n=================================================================\n"
echo "This next step will use dd to fill the remaining empty space with"
echo "zeros so it can be compacted out. This next step will look like a"
echo "failure with an error that looks like the following:"
echo "default: dd: error writing '/compact': No space left on device"
echo "but that is expected, and is not an actual failure or error."
echo "\n.................................................................\n"
dd if=/dev/zero of=/compact bs=1M || true
rm -f /compact
echo "\n=================================================================\n"

# parting message
date
echo "DONE! repackage VM into box with:"
echo "vagrant package --output my-cool.box"

# clear shell history
cat /dev/null > ~/.bash_history && history -c && exit
