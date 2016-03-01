# install sysdig, from their debian/ubuntu apt repo,
# following http://www.sysdig.org/install/
# gpg key is from https://s3.amazonaws.com/download.draios.com/DRAIOS-GPG-KEY.public
#
{%- set linux_version = salt['cmd.run']('uname -r') %}
{%- set linux_headers = 'linux-headers-' ~ linux_version %}

sysdig-dependencies:
  pkg.installed:
    - pkgs:
        - {{ linux_headers }}

sysdig:
  pkgrepo.managed:
    - name: 'deb http://download.draios.com/stable/deb stable-$(ARCH)/'
    - humanname: 'Sysdig Apt Repo'
    - file: '/etc/apt/sources.list.d/draios-sysdig.list'
    - key_url: salt://sysdig/files/DRAIOS-GPG-KEY.public
    - keyserver: keyserver.ubuntu.com
  pkg.installed:
    - name: sysdig
    - require:
        - pkgrepo: sysdig
        - pkg: sysdig-dependencies
    - refresh: True
