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

# clean up before exiting (we will create a box from this vm)
apt-get clean
dd if=/dev/zero of=/compact bs=1M
rm -f /compact

# parting message
echo "DONE! repackage VM into box with:"
echo "vagrant package --output my-cool.box"

# clear shell history
cat /dev/null > ~/.bash_history && history -c && exit
 
