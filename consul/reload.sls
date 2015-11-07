# setup a means to reload the consul config when any service check file is updated
# all service checks will use `watch_in` to update this state

{%- set home = '/home/consul' %}
{%- set user = 'consul' %}


consul-service-check-reload:
  cmd.run:
    - name: consul reload
    - chdir: {{ home }}
    - user: {{ user }}
