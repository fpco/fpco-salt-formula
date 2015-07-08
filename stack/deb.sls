stack.deb:
  file.managed:
    - source: 'https://s3.amazonaws.com/download.fpcomplete.com/ubuntu/trusty/pool/s/st/stack_0.1.1.0-1105-2cac22d_amd64.deb'
    - source_hash: 'sha256=b7299dbd47f17af6ee6ef18f8cb9ea7c9f054f7e870971721f6df3622ea89be8'
    - mode: '0644'
    - name: /usr/bin/stack.deb

install stack:
  cmd.run:
    - name: dpkg -i /usr/bin/stack.deb
    - require:
        - file: stack.deb
