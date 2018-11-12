{%- set default_domain = 'consul.' %}
{%- set domain = salt['pillar.get']('consul:domain', default_domain) %}

include:
  - dnsmasq.service

consul-dnsmasq:
  file.managed:
    - name: /etc/dnsmasq.d/10-consul
    - contents: "server=/{{ domain }}/127.0.0.1#8600"
    - watch_in:
        - service: dnsmasq
