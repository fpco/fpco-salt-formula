# install the salt-minion package
salt-minion-pkg:
  pkg.installed:
    - name: salt-minion
