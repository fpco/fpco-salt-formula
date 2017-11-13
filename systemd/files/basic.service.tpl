[Unit]
Description={{ description }}

[Service]
ExecStart={{ bin_path }} {{ args }}
WorkingDirectory={{ chdir }}
Restart=on-failure
User={{ run_as }}

[Install]
WantedBy=multi-user.target
