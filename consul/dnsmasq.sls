include:
  - dnsmasq.service

consul-dnsmasq:
  file.managed:
    - name: /etc/dnsmasq.d/10-consul
    - contents: "server=/consul/127.0.0.1#8600"
    - watch_in:
        - service: dnsmasq
