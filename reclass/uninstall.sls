# additional instructions are available:
# http://reclass.pantsfullofunix.net/install.html
# uninstall with the following:
# rm -r /usr/local/lib/python*/dist-packages/reclass* /usr/local/bin/reclass*

uninstall_reclass:
  cmd.run:
    - name: rm -r /usr/local/lib/python*/dist-packages/reclass* /usr/local/bin/reclass*
    - user: root
