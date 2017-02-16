# install kubectl (client executable) from the kubernetes release tarball on github
{% from "kubernetes/kubectl/checksum_map.jinja" import kubectl_map with context %}

{%- set default_version = '1.5.2' %}
{%- set version = salt['pillar.get']('kubectl:version', default_version) %}
{%- set default_checksum = kubectl_map[version] %}
{%- set checksum = salt['pillar.get']('kubectl:release_checksum', default_checksum) %}
{%- set bin_root = '/usr/local/bin' %}
{%- set app = 'kubectl' %}
{%- set bin_path = bin_root ~ '/' ~ app %}
# eg curl -O https://storage.googleapis.com/kubernetes-release/release/v1.4.3/bin/linux/amd64/kubectl
{%- set release_url = 'https://storage.googleapis.com/kubernetes-release/release/v' ~ version ~ '/bin/linux/amd64/kubectl' %}

kubectl-bin:
  file.managed:
    - name: {{ bin_path }}-{{ version }}
    - source: {{ release_url }}
    - source_hash: sha512={{ checksum }}
    - user: root
    - mode: 755

kubectl-symlink:
  # use a symlink to allow multiple versions, with a primary that is active
  file.symlink:
    - name: {{ bin_path }}
    - target: {{ bin_path }}-{{ version }}
    - require:
        - file: kubectl-bin
  # confirm we get what we expect
  cmd.run:
    - name: "which kubectl && {{ bin_path }} version || true"
    - require:
        - file: kubectl-symlink
