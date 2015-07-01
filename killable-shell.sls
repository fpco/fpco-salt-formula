killable-shell:
  file.managed:
    - name: /usr/local/bin/killable-shell.sh
    - user: root
    - group: root
    - mode: 755
    - contents: |
        #!/bin/sh
        # MANAGED BY SALT, MANUAL EDITS MAY BE OVERWRITTEN
        # killable-shell.sh: Kills itself and all children (the whole process group) when killed.
        # Adapted from http://stackoverflow.com/a/2173421 and http://veithen.github.io/2014/11/16/sigterm-propagation.html
        # Note: Does not work (and cannot work) when the shell itself is killed with SIGKILL, for then the trap is not triggered.
        trap "trap - SIGTERM && echo 'Caught SIGTERM, sending SIGTERM to process group' && kill -- -$$" SIGINT SIGTERM EXIT
        
        echo $@
        "$@" &
        PID=$!
        wait $PID
        trap - SIGINT SIGTERM EXIT
        wait $PID
        # end of script
