#MAKEFLAGS = -s

.PHONY: clean box import single multi

.DEFAULT_GOAL = help

## remove foundation.box
clean:
	rm -f foundation.box

## use vagrant and the Vagrantfile.box to build a .box we can import into vagrant
box:
	#git checkout top.sls
	cp Vagrantfile.box Vagrantfile
	vagrant destroy --force
	vagrant up
	vagrant package --output foundation.box

## use vagrant package to import the .box file, made availble use in a Vagrantfile
import:
	vagrant box add --force fpco/foundation foundation.box

## use vagrant and Vagrantfile.single to build a hashistack on a single VM
single:
	cp Vagrantfile.single Vagrantfile
	vagrant destroy --force
	vagrant up

## use vagrant and Vagrantfile.single to build a hashistack on a single VM
multi:
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
