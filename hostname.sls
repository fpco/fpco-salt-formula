{%- set hostname = salt['pillar.get']('hostname', grains['fqdn']) %}

hostname:
  file.managed:
    - name: /etc/hostname
    - user: root
    - group: root
    - mode: 0644
    - contents: {{ hostname }}
  {%- if salt['grains.get']('oscodename') == 'trusty' %}
  service.running:
    - name: hostname
    - watch:
        - file: hostname
    - watch_in:
        - module: hostname-refresh_grains
  {%- endif %}

{# if we update the system hostname, we need to reload grains #}
hostname-refresh_grains:
  module.wait:
    - name: saltutil.refresh_modules

# update /etc/hosts
localhost:
  host.only:
    - name: 127.0.0.1
    - hostnames:
        - localhost
fqdn:
  host.only:
    - name: 127.0.1.1
    - hostnames:
        - {{ hostname }}

