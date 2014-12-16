iam:
  user.present:
    - name: ur
  cmd.run:
    - name: echo "hello from `whoami`!"
    - user: ur
    - require:
        - user: iam
