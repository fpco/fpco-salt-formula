### Pillar Available

Here are the pillar keys available:

    openldap:
      config:
        key: value


Where `key` and `value` are any legal config key / value according to OpenLDAP.


### Additional Notes

Depending on the details of your LDAP requirements, you may need to clearly
define the hostname of the OpenLDAP server in its own `/etc/hosts`

That is to say, you may need the following:

    127.0.0.1 ldap.my.domain.com localhost ldap
