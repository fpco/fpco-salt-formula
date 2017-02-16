# install kubectl (client executable) from the kubernetes release tarball on github
{% from "kubernetes/release_map.jinja" import kube_release_checksum_map with context %}

{%- set default_version = '1.3.6' %}
{%- set version = salt['pillar.get']('kubernetes:version', default_version) %}
{%- set default_checksum = kube_release_checksum_map[version] %}
{%- set checksum = salt['pillar.get']('kubernetes:release_checksum', default_checksum) %}
{%- set bin_root = '/usr/local/bin' %}
{%- set app = 'kubectl' %}
{%- set bin_path = bin_root ~ '/' ~ app %}
{%- set kubectl_extract_path = 'kubernetes/platforms/linux/amd64/' ~ app %}
# eg https://github.com/kubernetes/kubernetes/releases/download/v1.1.2/kubernetes.tar.gz
{%- set release_url = 'https://github.com/kubernetes/kubernetes/releases/download/v' ~ version ~ '/kubernetes.tar.gz' %}

kubectl:
  archive.extracted:
    - name: {{ bin_root }}
    - source: {{ release_url }}
    - source_hash: sha512={{ checksum }}
    - if_missing: {{ bin_path }}-{{ version }}
    - archive_format: tar
    # use --strip-components and --transform together, to simplify the path and
    # extract the one file we want to the path we want this looks like:
    # 'zvp -C /usr/local/bin --strip-components=4 --transform=s,kubectl,kubectl-1.1.2, kubernetes/platforms/linux/amd64/kubectl'
    - tar_options: 'zvp -C {{ bin_root }} --strip-components=4 --transform=s,{{ app }},{{ app }}-{{ version }}, {{ kubectl_extract_path }}'
  # use a symlink to allow multiple versions, with a primary that is active
  file.symlink:
    - name: {{ bin_path }}
    - target: {{ bin_path }}-{{ version }}
    - require:
        - archive: kubectl
  # confirm we get what we expect
  cmd.run:
    - name: "which kubectl && {{ bin_path }} version || true"
    - require:
        - file: kubectl
