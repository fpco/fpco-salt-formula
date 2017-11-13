[Unit]
Description={{ description }}

[Service]
ExecStart={{ bin_path }} {{ cmd_args }}
WorkingDirectory={{ chdir }}
Restart=on-failure
User={{ run_as }}

[Install]
WantedBy=multi-user.target
