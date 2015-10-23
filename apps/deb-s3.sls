# from https://github.com/krobertson/deb-s3
# gem install deb-s3

include:
  - ruby

deb-s3:
  gem.installed:
    - name: deb-s3
    - require:
        - module: ruby-gem-refresh-salt-modules
