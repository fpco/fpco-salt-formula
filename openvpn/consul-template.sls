# create consul-template config for the openvpn.docker formula!

# keys required in the consul KV:
#
# openvpn-server/config
#                ovpn_env
#                ca_crt
#                dh_pem
#                ta_key
#                vpn_crt
#                vpn_key
#

{%- set consul_home = '/home/consul' %}
{%- set user = 'consul' %}
{%- set consul_conf_path = consul_home + 'conf.d' %}
{%- set tpl_conf_path = consul_home + '/template-tool' %}
{%- set template_path = '/srv/consul-templates' %}
{%- set ovpn_conf_path = '/etc/openvpn' %}

include:
  - consul.template-tool.service


consul-tpl-openvpn-server-template-path:
  file.directory:
    - name: {{ template_path }}/openvpn-server
    - user: {{ user }}
    - group: {{ user }}
    - mode: 640


consul-tpl-config-openvpn-server:
  file.managed:
    - name: {{ tpl_conf_path }}/openvpn-server.hcl
    - user: {{ user }}
    - group: {{ user }}
    - mode: 640
    - contents: |
        template {
          source = "{{ template_path }}/openvpn-server/openvpn.conf.tpl"
          destination = "{{ ovpn_conf_path }}/openvpn.conf"
          command = "service openvpn restart"
        }
        template {
          source = "{{ template_path }}/openvpn-server/ovpn_env.sh.tpl"
          destination = "{{ ovpn_conf_path }}/ovpn_env.sh"
          command = "service openvpn restart"
        }
        template {
          source = "{{ template_path }}/openvpn-server/ca.crt.tpl"
          destination = "{{ ovpn_conf_path }}/pki/ca.crt"
          command = "service openvpn restart"
        }
        template {
          source = "{{ template_path }}/openvpn-server/dh.pem.tpl"
          destination = "{{ ovpn_conf_path }}/pki/dh.pem"
          command = "service openvpn restart"
        }
        template {
          source = "{{ template_path }}/openvpn-server/ta.key.tpl"
          destination = "{{ ovpn_conf_path }}/ta.key"
          command = "service openvpn restart"
        }
        template {
          source = "{{ template_path }}/openvpn-server/vpn.crt.tpl"
          destination = "{{ ovpn_conf_path }}/pki/issued/vpn.crt"
          command = "service openvpn restart"
        }
        template {
          source = "{{ template_path }}/openvpn-server/vpn.key.tpl"
          destination = "{{ ovpn_conf_path }}/pki/private/vpn.key"
          command = "service openvpn restart"
        }
    - require:
        - file: consul-tpl-openvpn-server-template-path
    - watch_in:
        - service: consul-tpl-service


consul-tpl-template-openvpn-server-config:
  file.managed:
    - name: {{ template_path }}/openvpn-server/openvpn.conf.tpl
    - user: root
    - group: root
    - mode: 640
    - contents: {% raw %}{{ key "openvpn-server/config" }}{% endraw %}
    - require:
        - file: consul-tpl-templates-path
    - watch_in:
        - service: consul-tpl-service

consul-tpl-template-ovpn-env-sh:
  file.managed:
    - name: {{ template_path }}/openvpn-server/ovpn_env.sh.tpl
    - user: root
    - group: root
    - mode: 640
    - contents: {% raw %}{{ key "openvpn-server/ovpn_env" }}{% endraw %}
    - require:
        - file: consul-tpl-templates-path
    - watch_in:
        - service: consul-tpl-service

consul-tpl-template-openvpn-ca-cert:
  file.managed:
    - name: {{ template_path }}/openvpn-server/ca.crt.tpl
    - user: root
    - group: root
    - mode: 640
    - contents: {% raw %}{{ key "openvpn-server/ca_crt" }}{% endraw %}
    - require:
        - file: consul-tpl-templates-path
    - watch_in:
        - service: consul-tpl-service

consul-tpl-template-openvpn-dh-pem:
  file.managed:
    - name: {{ template_path }}/openvpn-server/dh.pem.tpl
    - user: root
    - group: root
    - mode: 640
    - contents: {% raw %}{{ key "openvpn-server/dh_pem" }}{% endraw %}
    - require:
        - file: consul-tpl-templates-path
    - watch_in:
        - service: consul-tpl-service

consul-tpl-template-openvpn-ta-key:
  file.managed:
    - name: {{ template_path }}/openvpn-server/ta.key.tpl
    - user: root
    - group: root
    - mode: 640
    - contents: {% raw %}{{ key "openvpn-server/ta_key" }}{% endraw %}
    - require:
        - file: consul-tpl-templates-path
    - watch_in:
        - service: consul-tpl-service

consul-tpl-template-openvpn-vpn-crt:
  file.managed:
    - name: {{ template_path }}/openvpn-server/vpn.crt.tpl
    - user: root
    - group: root
    - mode: 640
    - contents: {% raw %}{{ key "openvpn-server/vpn_crt" }}{% endraw %}
    - require:
        - file: consul-tpl-templates-path
    - watch_in:
        - service: consul-tpl-service

consul-tpl-template-openvpn-vpn-key:
  file.managed:
    - name: {{ template_path }}/openvpn-server/vpn.key.tpl
    - user: root
    - group: root
    - mode: 640
    - contents: {% raw %}{{ key "openvpn-server/vpn_key" }}{% endraw %}
    - require:
        - file: consul-tpl-templates-path
    - watch_in:
        - service: consul-tpl-service

