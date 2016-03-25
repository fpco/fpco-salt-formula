# Create the `config` and `credentials` files for AWS CLI utilities.
#
# aws_users:
#   root:
#     profiles:
#       default:
#         access: FOO
#         secret: FOOBAR
#         output: json
#         region: us-east-1
#       profile2:
#         access: BAR
#         secret: BARBAZ
#         output: json
#         region: us-west-1
#   foobar:
#     profiles:
#       default:
#         access: FOOBAR
#         ...

{%- macro cred_entry(name, profile) %}
  [{{ name }}]
  aws_access_key_id={{ profile['access'] }}
  aws_secret_access_key={{ profile['secret'] }}
{%- endmacro %}

{%- macro conf_entry(name, profile) %}
  {%- if name != "default" %}
  [profile {{ name }}]
  {%- else %}
  [default]
  {%- endif %}
  region={{ profile['region'] }}
  output={{ profile['output'] }}
{%- endmacro %}

{%- set users = salt['pillar.get']('aws_users', {}) %}

{%- for user, userdata in users.items() %}
  {%- set get_home = 'getent passwd "' ~ user ~'" | cut -d: -f6' %}
  {%- set home = salt['cmd.run'](get_home) %}

aws-credentials-{{ user }}:
  file.managed:
    - name: {{ home }}/.aws/credentials
    - user: {{ user }}
    - group: {{ user }}
    - mode: 600
    - makedirs: True
    - contents: |
        {%- for name, profile in userdata['profiles'].items() -%}
        {{ cred_entry(name, profile) | indent(8) }}
        {% endfor %}

aws-config-{{ user }}:
  file.managed:
    - name: {{ home }}/.aws/config
    - user: {{ user }}
    - group: {{ user }}
    - mode: 600
    - makedirs: True
    - contents: |
        {%- for name, profile in userdata['profiles'].items() -%}
        {{ conf_entry(name, profile) | indent(8) }}
        {% endfor %}

{%- endfor %}
