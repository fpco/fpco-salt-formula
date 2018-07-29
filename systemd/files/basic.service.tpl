[Unit]
Description={{ description }}
Requires={{ requires }}
After={{ requires }}

[Service]
ExecStart={{ bin_path }} {{ bin_opts }}
Restart=on-failure
{% if chdir is defined %}WorkingDirectory={{ chdir }}{% endif %}
{% if runas_user is defined %}User={{ runas_user }}{% endif %}
{% if runas_group is defined %}Group={{ runas_group }}{% endif %}

[Install]
WantedBy=multi-user.target
