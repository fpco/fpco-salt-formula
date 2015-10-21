openntpd:
  server_pool: {%- raw %}{{range service "ntpd"}}
    - {{.Address}}{{end}}{%- endraw %}
