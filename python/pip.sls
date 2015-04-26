# ensure pip is installed, through apt, and salt's modules are reloaded

include:
  - python


pip:
  cmd.run:
    - name: easy_install -U pip
    - unless: which pip
    - require:
        - pkg: python-setuptools


# if we update the pip package, we need to reload modules
pip-refresh_modules:
  module.wait:
    - name: saltutil.refresh_modules
    - watch:
        - cmd: pip
