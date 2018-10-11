## Vagrant Env for Devops R&D

This repo includes a vagrant env that aims to

* demonstrate what can be done with the formula
* giving devops developers an easy way to explore the components in the stack
  and expand the features available

This is the first step in a series of tutorials on this topic.

### Install Vagrant

Visit the [vagrant docs][vagrant-docs] to download and install vagrant.

### Get the source code

Clone the [fpco/fpco-salt-formula repo][fsf-repo] to get started.

### Start the Vagrant VM

Run `vagrant up` from within the root of the `fpco-salt-formula` repo.

This will run an initialization/provisioning process on the VM, and will take
5 to 10 minutes, just sit tight while that runs.

### SSH and explore

Next run `vagrant ssh` to SSH into the vagrant box you have just provisioned.

Use `sudo su -l` to switch to `root` and explore the VM env provided via the
following tutorials:

* add more

[vagrant-docs]: https://www.vagrantup.com/downloads.html
[fsf-repo]: https://github.com/fpco/fpco-salt-formula
