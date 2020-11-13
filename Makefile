#MAKEFLAGS = -s

.PHONY: clean box import single multi

.DEFAULT_GOAL = help

## remove foundation.box
clean:
	rm -f foundation.box

## use vagrant and the Vagrantfile.box to build a .box we can import into vagrant
build-foundation:
	#git checkout top.sls
	cp Vagrantfile.box Vagrantfile
	vagrant destroy --force
	vagrant up

## use Vagrant to package the foundation box, writing it to a file that can be imported
pkg-foundation:
	vagrant package --output foundation.box

## use vagrant package to import the foundation.box file, made available for use in a Vagrantfile
import-foundation:
	vagrant box add --force fpco/foundation-bionic foundation.box

## use vagrant and Vagrantfile.single to build a hashistack on a single VM
build-single:
	cp Vagrantfile.single Vagrantfile
	vagrant destroy --force
	vagrant up

## use vagrant and the single box just built to create an importable box for the "single node" build
pkg-single:
	vagrant package --output single.box

## use vagrant package to import the single.box file, made availble to use in a Vagrantfile
import-single:
	vagrant box add --force fpco/hashi-stack-bionic single.box

## (WIP, not funcitonal) use vagrant and Vagrantfile.single to build a hashistack on a multiple VM
build-multi:
	cp Vagrantfile.multi Vagrantfile
	vagrant destroy --force
	vagrant up

## Show help screen.
help:
	@echo "Please use \`make <target>' where <target> is one of\n\n"
	@awk '/^[a-zA-Z\-\_0-9]+:/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = substr($$1, 0, index($$1, ":")-1); \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			printf "%-30s %s\n", helpCommand, helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)
