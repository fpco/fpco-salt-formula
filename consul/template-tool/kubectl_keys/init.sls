# the purpose of this formula is to generate a bunch of states which create and
# manage config snippets and templates for consul-template to read a certs and
# config for the kubectl (associated with a named cluster). This formula will
# iterate over a set of clusters, and put in place the consul-template config
# needed to monitor these keys stored in vault, and to retrieve/write them out
# to files on the host when the keys in vault change.
{%- from "vault/kubectl_keys/distribute_keys_macro.sls" import render_keys with context %}
{%- set kube_clusters = salt['pillar.get']('kube_clusters', {}) %}


{%- for cluster, config in kube_clusters.items() %}

{%- set config_path = config['kube_home'] ~ '/' ~ cluster %}

kube-cluster-{{ cluster }}-config-home:
  file.directory:
    - name: {{ config_path }}
    - user: {{ config['kube_user'] }}
    - mode: 750
    - makedirs: True

{{ render_keys(cluster, config['vault_path'], config_path) }}

{% endfor %}
