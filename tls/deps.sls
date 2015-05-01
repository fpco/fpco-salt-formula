python-openssl:
  pip.installed:
    - name: PyOpenSSL
  module.wait:
    - name: saltutil.refresh_modules
    - watch:
        - pip: python-openssl
