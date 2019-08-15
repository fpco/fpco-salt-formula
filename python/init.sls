# install python and setuptools, leave pip to python.pip and dev to python.dev

python:
  pkg.installed:
    - name: python3

python-setuptools:
  pkg.installed:
    - name: python3-setuptools
    - require:
        - pkg: python
