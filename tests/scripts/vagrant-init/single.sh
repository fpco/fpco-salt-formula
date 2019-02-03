#!/usr/bin/env bash

echo hostname: $(hostname)
sed -i 's/foundation/'$(hostname)'/' /etc/hosts
salt-call --local state.sls hostname,salt.minion --log-level=debug

# this will use reclass config to control contents of top.sls
# when creating a base box, we aim to install tools, not run them
# the node/class mapping controls this, edit bootstrap pillar to customize
salt-call --local state.sls reclass.managed_tops --log-level=debug

# using the updated top.sls, run highstate (all formula in node's top.sls)
# this will configure and run the hashistack
salt-call --local state.highstate --log-level=debug

# reload dnsmasq during highstate doesn't work, restart now so it uses the
# updated config for consul integration
service dnsmasq restart

# open ports so we can access devops services deployed on the host (later)
ufw allow 9090 # prometheus
ufw allow 9100 # node_exporter
ufw allow 9111 # consul-exporter
ufw allow 9172 # nomad-exporter
ufw allow 3000 # grafana
ufw allow 5000 # hashi-ui
ufw allow 8500 # consul
ufw allow 8200 # vault
ufw allow 4646 # nomad
ufw allow 9999 # fabio
ufw allow 9998 # fabio-admin

# what is the vault service's current status?
service vault status

# sleep before continuing, in case consul/vault aren't ready just yet
echo "pause to let vault/consul services come online"
sleep 30

# tell the vault client where to find our vault server
# state.highstate has been run, we have all the ADDRs, just need to source it
source /etc/environment
