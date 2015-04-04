ldap:
  pkg.installed:
    - pkgs:
        - slapd
        - ldap-utils
  file.managed:
    - name: /etc/ldap/ldap.conf
    - source: salt://openldap/files/etc/ldap/ldap.conf
    - template: jinja
    - context:
        config: {{ salt['pillar.get']('ldap:config', {}) }}
    - user: root
    - group: root
    - mode: 644
    - makedirs: True
    - require:
        - pkg: ldap
  service.running:
    - name: slapd
    - enable: True
    - watch:
        - pkg: ldap
        - file: ldap
