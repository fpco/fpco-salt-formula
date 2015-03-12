# Create the `config` and `credentials` files for AWS CLI utilities.                                     
# For now, this is limited to a specific user, though this is easy to update                             
# with iteration.                                                                                        
#
# The pillar is a little more complicated than usual, so we'll include example:                          
#   
# aws:
#   users:
#     key: FOO                                                                                           
#     secret: FOOBAR                                                                                     
#     output: json
#     region: us-east-1
#   root:
#     key: ...
#     ...
#       
        
{%- set user = salt['pillar.get']('user', 'root') %}                                                     
{%- set home = salt['pillar.get']('home', '/root') %}                                                    
{%- set config = salt['pillar.get']('aws:users', {}) %}                                                  
  
{%- set user_conf = config[user] or {} %}                                                                
{%- set region = user_conf['region'] or 'us-east-1' %}                                                   
{%- set output = user_conf['output'] or 'json' %}                                                        
{%- set key = user_conf['key'] or 'FOOBAR' %}                                                            
{%- set secret = user_conf['secret'] or 'FOOBAR' %}                                                      
    
      
aws-credentials:
  file.managed:
    - name: {{ home }}/.aws/credentials                                                                  
    - user: {{ user }}
    - group: {{ user }}
    - mode: 600
    - contents: |
        [default]
        aws_access_key_id = {{ key }}
        aws_secret_access_key = {{ secret }}

aws-config:
  file.managed:
    - name: {{ home }}/.aws/config
    - user: {{ user }}
    - group: {{ user }}
    - mode: 600
    - contents: |
        [default]
        output = {{ output }}
        region = {{ region }}
