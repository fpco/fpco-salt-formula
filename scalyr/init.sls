{%- set api_key = salt['pillar.get']('scalyr:api_key', 'FOOBAR') %}
{%- set conf_dir = '/etc/scalyr-agent-2' %}
{%- set host = salt['grains.get']('id') %}

scalyr-config-dir:
  file.directory:
    - name: {{ conf_dir }}/agent.d
    - user: root
    - group: root
    - mode: 750


scalyr-config-file:
  file.managed:
    - name: {{ conf_dir }}/agent.json
    - user: root
    - group: root
    - mode: 640
    - contents: |
        // Configuration for the Scalyr Agent. For help:
        // 
        // https://www.scalyr.com/help/scalyr-agent-2
        {
          // Enter a "Write Logs" api key for your account. These are available at https://www.scalyr.com/keys
          api_key: "{{ api_key }}",
        
          // Fields describing this server. These fields are attached to each log message, and
          // can be used to filter data from a particular server or group of servers.
          server_attributes: {
             // Fill in this field if you'd like to override the server's hostname.
             serverHost: "{{ host }}",
        
             // You can add whatever additional fields you'd like.
             env: "production"
             app: "stackage-server"
          }
        
          // Log files to upload to Scalyr. You can use '*' wildcards here.
          logs: [
             { path: "/var/log/upstart/stackage-server.log", attributes: {parser: "accessLog"} }, 
             { path: "/var/log/dmesg.log", attributes: {parser: "systemLog"} }
             // { path: "/var/log/auth.log", attributes: {parser: "systemLog"} },
             // { path: "/var/log/syslog", attributes: {parser: "systemLog"} },
             // { path: "/var/log/ufw.log", attributes: {parser: "systemLog"} }
          ],
        
          monitors: [
        //  {
        //    module: "scalyr_agent.builtin_monitors.url_monitor",
        //    id:     "{{ host }}-stackage-server-status",
        //    url:    "http://localhost:3000/"
        //  }
          ]
        }

