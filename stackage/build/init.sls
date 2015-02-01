{%- set git_home = salt['pillar.get']('src:git:home', '/usr/src') %}
{%- set git_user = salt['pillar.get']('src:git:user', 'root') %}

include:
  - fpbuild
  - git.repos


build-stackage-server:
  cmd.run:
    - name: fpbuild build
    - cwd: {{ git_home }}/stackage-server/
    - user: {{ git_user }}
    - watch:
        - git: stackage-server-git


build-stackage:
  file.managed:
    - name: {{ git_home }}/stackage/fpbuild.config
    - user: {{ git_user }}
    - contents: |
        docker:
          repo-suffix: "_ghc-7.8.4.20141229_stackage-lts-1.0"
          image-tag: "20150101"
        packages:
          - "."
  cmd.run:
    - name: fpbuild build
    - cwd: {{ git_home }}/stackage/
    - user: {{ git_user }}
    - watch:
        - git: stackage-git
