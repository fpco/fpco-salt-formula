mosh:
  pkg.absent:
    - name: mosh
  cmd.run:
    - name: ufw delete allow 60001
