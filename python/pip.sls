# ensure pip is installed, through apt, and salt's modules are reloaded

include:
  - python


pip:
  cmd.run:
    - name: easy_install -U pip
    - unless: which pip
    - require:
        - pkg: python-setuptools
  module.wait:
    - name: saltutil.refresh_modules
    - watch:
        - cmd: pip
  # upgrade pip with pip, now that we have it installed and available
  pip.installed:
    - name: pip > 1.5
    - require:
        - cmd: pip
        - module: pip


# if we update the pip package, we need to reload modules
pip-refresh_modules:
  module.wait:
    - name: saltutil.refresh_modules
    - watch:
        - pip: pip
