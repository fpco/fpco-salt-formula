# installs jq directly from github. Example:
# https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64
#
{%- from "macros/executables.sls" import install_executable with context %}

{%- set name = 'jq' %}
{%- set version = '1.5' %}
{%- set base_url = 'https://github.com/stedolan/jq/releases/download' %}
{%- set release_bin = 'jq-linux64' %}
{%- set file_url = base_url ~ '/' ~ 'jq-' ~ version ~ '/' ~ release_bin %}
{%- set checksum = 'aaa016d57ab8351360d02186809ade9cdecd3eb20df7a8cf05cd5d1037c4d36efae9e1bb0102d175c91b530b0309f24b48d579544249da7cbd50f721332617b9' %}

{{ install_executable(name, file_url, checksum, version) }}
