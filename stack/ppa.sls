# roughly speaking, this is equivalent to the following:
#
#     wget -q -O- http://download.fpcomplete.com/ubuntu/fpco.key | sudo apt-key add -
#     echo 'deb http://download.fpcomplete.com/ubuntu/`lsb_release -cs` stable main'|sudo tee /etc/apt/sources.list.d/fpco.list
#     sudo apt-get update
#     sudo apt-get install stack -y

stack:
  pkgrepo.managed:
    - name: deb http://download.fpcomplete.com/ubuntu/{{ salt['grains.get']('lsb_distrib_codename') }} stable main
    - key_url: http://download.fpcomplete.com/ubuntu/fpco.key
    - file: /etc/apt/sources.list.d/fpco.list
  pkg.latest:
    - name: stack
    - require:
        - pkgrepo: stack
