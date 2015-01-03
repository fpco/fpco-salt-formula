packer:
  pkg.installed:
    - name: unzip
  archive.extracted:
    - name: /usr/local/bin/
    - if_missing: /usr/local/bin/packer
    - source: https://dl.bintray.com/mitchellh/packer/packer_0.7.5_linux_amd64.zip
    - source_hash: sha256=8fab291c8cc988bd0004195677924ab6846aee5800b6c8696d71d33456701ef6
    - archive_format: zip
    - archive_user: root
    - require:
        - pkg: packer
  cmd.run:
    - name: packer version
    - require:
        - archive: packer
