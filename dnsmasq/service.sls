dnsmasq:
  file.managed:
    - name: /etc/dnsmasq.d/00-localhost
    - user: root
    - group: root
    - mode: 640
    - contents: |
        # edits will be lost, contents auto-managed by salt
        # only listen on localhost address and interface
        interface=lo
        listen-address=127.0.0.1
        # disable DHCP, this is DNS only
        no-dhcp-interface=lo
        # bind to the localhost interface, no passive monitor
        bind-interfaces
  service.running:
    - name: dnsmasq
    - reload: True
    - enable: True
    - watch:
        - file: dnsmasq
