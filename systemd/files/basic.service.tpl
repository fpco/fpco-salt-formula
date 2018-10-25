[Unit]
Description={{ description }}
Requires={{ requires }}
After={{ requires }}

[Service]
{% if pre_start is defined %}ExecStartPre={{ pre_start }}{% endif %}
{% if env_file is defined %}EnvironmentFile={{ env_file }}{% endif %}
ExecStart={{ bin_path }} {% if bin_opts is defined %}{{ bin_opts }}{% endif %}
Restart=on-failure
{% if chdir is defined %}WorkingDirectory={{ chdir }}{% endif %}
{% if runas_user is defined %}User={{ runas_user }}{% endif %}
{% if runas_group is defined %}Group={{ runas_group }}{% endif %}

[Install]
WantedBy=multi-user.target
