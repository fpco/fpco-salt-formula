[Unit]
{% for k,v in unit_params.items() %}
{{ k }}={{ v }}
{% endfor %}

[Service]
{% for k,v in service_params.items() %}
{{ k }}={{ v }}
{% endfor %}

[Install]
{% for k,v in install_params.items() %}
{{ k }}={{ v }}
{% endfor %}

