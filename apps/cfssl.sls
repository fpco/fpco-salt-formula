# install cfssl suite from pkg.cfssl.org, eg
# https://pkg.cfssl.org/R1.2/cfssl-bundle_linux-amd64

{%- from 'macros/executables.sls' import install_executable with context %}

{%- set version = '1.2' %}
{%- set base_url = 'https://pkg.cfssl.org/R' ~ version %}
{%- set arch = 'linux-amd64' %}
{%- set file_list = ['cfssl-bundle', 'cfssl-certinfo', 'cfssl-newkey', 'cfssl-scan',
                 'cfssl', 'cfssljson', 'mkbundle', 'multirootca'] %}
{%- set checksum = {
           'cfssl-bundle': '3a17328f2fa64252ddef691fcd36966d3ea7e9be0eb4f768cd1387a5151aa7caac9dcfade6054ab1be56595c05c33b52a30a178a3dcbdbb240ec521408518895',
           'cfssl-certinfo': '4df2fb239a1d8767e23886e0429a3aabe2cc06befb83c3432d4e1978fbb48f0139dbad10897a17180e48c738b378316d93ade8e65b1e709b604307a2e2caa4ab',
           'cfssl-newkey': 'f4c2ddc0bd3b1f7123c24a746b6057086f0b14ac9eb9bbd6f89def54a74a40d14cb1596751d9dbcff2c496e189442e1fbb2a24b631660223fc470561a8a736fa',
           'cfssl-scan': '2de0e9d9c353c5ed58cc70d8682b4290301b82daf3a37928cd71d5ed9dd01aadfebc4507975d89ffd24a0c33b38e94dd7ccb6835461a3708cf38d83bb4a40f2b',
           'cfssl': '344d58d43aa3948c78eb7e7dafe493c3409f98c73f27cae041c24a7bd14aff07c702d8ab6cdfb15bd6cc55c18b2552f86c5f79a6778f0c277b5e9798d3a38e37',
           'cfssljson': 'b80f19e61e16244422ad3d877e5a7df5c46b34181d264c9c529db8a8fc2999c6a6f7c1fb2dec63e08d311d6657c8fe05af3186b7ff369a866a47d140d393b49b',
           'mkbundle': 'ae595ef5074117747722b41ac0786d81126cfcf8d9ef8e4770e1edae7c522406a1361dde6948ea637862cf4f57730bd64d0fa94c4ef69f5d1c250695ff54b2f7',
           'multirootca': 'adc63fe980192448036e65ab3eca26c348262218432ce7a2e36cba5a7273614db01fcee69e67e2844e746f4b68ecc678d02b4c3c21cb2c046a6e5fe468756735',
        } %}
{%- set help_flag = '--help || true' %}

{%- for exec in file_list %}
{%- set file_name = exec ~ '_' ~ arch %}
{%- set url = base_url ~ '/' ~ file_name %}
{{ install_executable(exec, url, checksum[exec], version, flag=help_flag) }}
{%- endfor %}
