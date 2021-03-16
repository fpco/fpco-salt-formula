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

restart-resolved:
  cmd.waiting:
    - name: service systemd-resolved restart
    - watch:
        - file: consul-systemd-resolved-conf

consul-systemd-resolved-conf:
  file.managed:
    - name: /etc/systemd/resolved.conf
    - watch_in:
        - cmd: restart-resolved
    - contents: |
        #  This file is part of systemd.
        #
        #  systemd is free software; you can redistribute it and/or modify it
        #  under the terms of the GNU Lesser General Public License as published by
        #  the Free Software Foundation; either version 2.1 of the License, or
        #  (at your option) any later version.
        #
        # Entries in this file show the compile time defaults.
        # You can change settings by editing this file.
        # Defaults can be restored by simply deleting this file.
        #
        # See resolved.conf(5) for details

        # THIS FILE IS MANAGED BY SALTSTACK, DO NOT EXPECT CHANGES TO PERSIST

        [Resolve]
        DNS=127.0.0.1
        Domains=~{{ domain }}
    - require:
        - file: consul-dnsmasq
