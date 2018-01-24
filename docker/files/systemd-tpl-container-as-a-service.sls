[Unit]
Description={{ desc }}
After=docker.service
Requires=docker.service

[Service]
{%- if env_vars is defined %}
{%- for var, val in env_vars.items() %}
Environment={{ var }}={{ val }}
{%- endfor %}
{%- endif %}
TimeoutStartSec=0
ExecStartPre=-/usr/bin/docker kill {{ container_name }}
ExecStartPre=-/usr/bin/docker rm {{ container_name }}
ExecStartPre=/usr/bin/docker pull {{ img }}:{{ tag }}
ExecStart=/usr/bin/docker run --detach {%- if port_number is defined %}-p {{ port_number }}:{{ port_number }}{%- endif %} --restart=always {%- if docker_args is defined %}{%- for arg in docker_args %}{{ arg }} {%- endfor %}{%- endif %} --name {{ container_name }} {{ img }}:{{ tag }}
ExecStop=/usr/bin/docker stop {{ container_name }}

[Install]
WantedBy=multi-user.target
