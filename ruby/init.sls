# install the most basic ruby/gem to make `gem install foo` possible

ruby:
  pkg.installed:
    - pkgs:
        - ruby-dev
        - gcc

# if we update the pip package, we need to reload modules
ruby-gem-refresh-salt-modules:
  module.wait:
    - name: saltutil.refresh_modules
    - watch:
        - pkg: ruby
