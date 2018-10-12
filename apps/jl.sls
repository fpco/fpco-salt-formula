{%- from "macros/executables.sls" import install_executable with context %}

{%- set checksum = '952186bbb90a1089dcf71c38161beac863b806fe9cc94e79ad587e3648451134a457ac3397322cb665e54eae5b36f37b3c33b97d09a7b7376ae26135471983d7' %}
{%- set file_url = 'https://github.com/chrisdone/jl/releases/download/v0.0.5/jl-linux' %}
{%- set name = 'jl' %}
{%- set version = '0.0.5' %}

{{ install_executable(name, file_url, checksum, version) }}
