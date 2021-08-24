{%- set conf_path = '/etc/consul/template-tool/' %}
{%- set log_path = '/var/log/consul-template-once.log' %}
{%- set log_it = ' >> ' ~ log_path ~ ' 2>&1' %}
{%- set bin = '/usr/local/bin/consul-template' %}
{%- set args = '-once -config=' ~ conf_path ~ log_it %}
{%- set run_consul_template = bin ~ ' ' ~ args %}
{%- set cron_frequency = salt['pillar.get']('consul_template:cron_frequency', '*/5') %}

consul-template-run-once-cron:
  cron.present:
    - name: {{ run_consul_template }}
    - identifier: consul-template-run-once
    - user: root
    - hour: '*'
    - minute: '{{ cron_frequency }}'
