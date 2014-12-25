#!/bin/sh

# ensure we can easily add apt repos/PPA
apt-get install -y python-software-properties
# this will give us latest saltstack
add-apt-repository ppa:saltstack/salt
# ensure we get zmq v4
add-apt-repository ppa:chris-lea/zeromq
# ensure PPAs are active and install!
apt-get update
apt-get install -y salt-minion
# disable the service until configured
service salt-minion stop
# where to put salt configs AND pillar/formula
export SALT_ROOT=/etc/salt
# make a home for salt configs
mkdir -p $SALT_ROOT/formula $SALT_ROOT/pillar
# symlink to keep rsync updates simple
ln -sf `pwd` $SALT_ROOT/formula/
# create a suitable minion config for local file roots/etc
cat <<EOF > $SALT_ROOT/minion
file_client: local
file_roots:
  base:
    - $SALT_ROOT/formula
pillar_roots:
  base:
    - $SALT_ROOT/pillar
EOF

# setup stackage binary

# here's the home stretch!
alias SALT="salt-call --local"
SALT saltutil.sync_all
SALT saltutil.refresh_modules
#SALT state.sls docker.install
#SALT saltutil.refresh_modules
#SALT state.sls stackage.server
