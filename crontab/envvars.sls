{%- set default_path  = '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin' %}
{%- set default_shell = '/bin/sh' %}

{%- set path  = salt['pillar.get']('crontab:path',  default_path)  %}
{%- set shell = salt['pillar.get']('crontab:shell', default_shell) %}

root-cron-env-var-PATH:
  cron.env_present:
    - name: PATH
    - user: root
    - value: "{{ path }}"

root-cron-env-var-SHELL:
  cron.env_present:
    - name: SHELL
    - user: root
    - value: "{{ shell }}"

