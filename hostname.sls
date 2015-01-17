hostname:
  file.managed:
    - name: /etc/hostname
    - user: root
    - group: root
    - mode: 0644
    - contents: {{ salt['pillar.get']('hostname', grains['fqdn']) }}
  service.running:
    - name: hostname
    - watch:
        - file: hostname

{# if we update the system hostname, we need to reload grains #}
hostname-refresh_grains:
  module.wait:
    - name: saltutil.refresh_modules
    - watch:
        - service: hostname
