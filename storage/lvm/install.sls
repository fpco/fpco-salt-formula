lvm-deps:
  pkg.latest:
    - pkgs:
        - lvm2
  module.run:
    - name: saltutil.refresh_modules
    - watch:
        - pkg: lvm-deps

