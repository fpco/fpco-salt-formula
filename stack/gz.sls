stack.deb:
  file.managed:
    - source: 'https://s3.amazonaws.com/download.fpcomplete.com/dev-tools/stack/stack-0.1.2.1-x86_64-linux.gz'
    - source_hash: 'sha256=7ed101e663c7d13135fc4c615de8456f9de299129401017900c6d46bc9ee5249'
    - mode: '0755'
    - name: /usr/bin/stack.gz

install stack:
  cmd.run:
    - name: gunzip --force --keep /usr/bin/stack.gz
    - require:
        - file: stack.deb
