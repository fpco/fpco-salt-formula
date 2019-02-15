{%- set install_to = '/usr/local/bin' %}
{%- set version = '1.9.3' %}
{%- set checksum = 'sha256=e2363728e5818ccc68db9371c15af892a9a1fc86d808d0a9a77257f13696e946' %}

stack.gz:
  file.managed:
    - source: 'https://github.com/commercialhaskell/stack/releases/download/v{{ version }}/stack-{{ version }}-linux-x86_64.tar.gz'
    - source_hash: '{{ checksum }}'
    - mode: '0755'
    - name: {{ install_to }}/stack.gz
  cmd.run:
    - name: tar -xzvf {{ install_to }}/stack.gz --strip-components=1 --wildcards -C {{ install_to }} */stack
    - require:
        - file: stack.gz
    - unless: stack --version

stack:
  cmd.run:
    - name: stack --version
    - require:
        - cmd: stack.gz
