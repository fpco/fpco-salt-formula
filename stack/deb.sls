stack.deb:
  file.managed:
    - source: 'https://s3.amazonaws.com/download.fpcomplete.com/dev-tools/stack/stack-0.1.2.1-x86_64-linux.gz'
    - source_hash: 'sha256=7ed101e663c7d13135fc4c615de8456f9de299129401017900c6d46bc9ee5249'
    - mode: '0644'
    - name: /usr/bin/stack.deb

install stack:
  cmd.run:
    - name: dpkg -i /usr/bin/stack.deb
    - require:
        - file: stack.deb
