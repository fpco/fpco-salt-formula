# from https://github.com/jordansissel/fpm/wiki
# apt-get install ruby-dev gcc
# gem install fpm

include:
  - ruby

fpm:
  gem.installed:
    - name: fpm
    - require:
        - module: ruby-gem-refresh-salt-modules
