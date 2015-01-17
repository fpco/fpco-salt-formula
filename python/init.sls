# install python and setuptools, leave pip to python.pip and dev to python.dev

python:
  pkg.installed:
    - name: python

python-setuptools:
  pkg.installed:
    - require:
        - pkg: python
