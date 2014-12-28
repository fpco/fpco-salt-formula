#!/bin/sh

# ensure we can easily add apt repos/PPA
apt-get install -y python-software-properties
# this will give us latest saltstack
add-apt-repository -y ppa:saltstack/salt
# ensure we get zmq v4
add-apt-repository -y ppa:chris-lea/zeromq
# ensure PPAs are active and install!
apt-get update
apt-get install -y salt-minion
# disable the service until configured
service salt-minion stop
# where to put salt configs AND pillar/formula
export SALT_ROOT=/etc/salt
CONFIG_PATH=$SALT_ROOT/minion
FILE_ROOT=$SALT_ROOT/formula
PILLAR_ROOT=$SALT_ROOT/pillar
# make a home for salt configs
mkdir -p $FILE_ROOT $PILLAR_ROOT
# symlink to keep rsync updates simple
#ln -sf `pwd` $SALT_ROOT/formula
rsync -avz `pwd`/ $FILE_ROOT/
# create a suitable minion config for local file roots/etc
cat <<EOF > $CONFIG_PATH
file_client: local
file_roots:
  base:
    - $FILE_ROOT
pillar_roots:
  base:
    - $PILLAR_ROOT
EOF

# setup stackage binary

# here's the home stretch!
alias SALT="salt-call --local"
SALT saltutil.sync_all
SALT saltutil.refresh_modules
#SALT state.sls docker.install
#SALT saltutil.refresh_modules
#SALT state.sls stackage.server
