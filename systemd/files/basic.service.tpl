[Unit]
Description={{ description }}

[Service]
ExecStart={{ bin_path }} {{ args }}
Restart=on-failure
{% if chdir %}WorkingDirectory={{ chdir }}{% endif %}
{% if run_as %}User={{ run_as }}{% endif %}

[Install]
WantedBy=multi-user.target
