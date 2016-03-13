# Create the `config` and `credentials` files for AWS CLI utilities.                                     
#
# aws:
#   users:
#     root:
#       access: FOO
#       secret: FOOBAR
#       output: json
#       region: us-east-1
#     foobar:
#       access: FOOBAR
#       ...

{%- set users = salt['pillar.get']('aws:users', {}) %}

{%- for user, conf in users.items() %}
  {%- set get_home = 'getent passwd "' ~ user ~'" | cut -d: -f6' %}
  {%- set home = salt['cmd.run'](get_home) %}
  {%- set region = conf['region'] %}
  {%- set output = conf['output'] %}
  {%- set access = conf['access'] %}
  {%- set secret = conf['secret'] %}

aws-credentials:
  file.managed:
    - name: {{ home }}/.aws/credentials
    - user: {{ user }}
    - group: {{ user }}
    - mode: 600
    - makedirs: True
    - contents: |
        [default]
        aws_access_key_id = {{ access }}
        aws_secret_access_key = {{ secret }}

aws-config:
  file.managed:
    - name: {{ home }}/.aws/config
    - user: {{ user }}
    - group: {{ user }}
    - mode: 600
    - makedirs: True
    - contents: |
        [default]
        output = {{ output }}
        region = {{ region }}

{%- endfor %}
