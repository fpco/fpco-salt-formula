[Unit]
Description={{ description }}

[Service]
ExecStart={{ bin_path }} {{ args }}
Restart=on-failure
{% if chdir is undefined %}WorkingDirectory={{ chdir }}{% endif %}
{% if run_as is undefined %}User={{ run_as }}{% endif %}

[Install]
WantedBy=multi-user.target
