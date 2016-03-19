{%- set cname = 'cog-relay' %}
{%- set docker_repo = 'operable/relay' %}
{%- set docker_tag = 'latest' %}
{%- set ip = '127.0.0.1' %}
{%- set hostname = salt['grains.get']('id') %}
{%- set data_dir = '/var/lib/cog-relay' %}
{%- set envvars = salt['pillar.get']('cog:relay:envvars', {}) %}
{%- set default_mqtt_host = 'cog-master.service.consul' %}
{%- set cog_mqtt_host = salt['pillar.get']('cog:relay:cog_mqtt_host', default_mqtt_host) %}
{%- do envvars.update({'COG_MQTT_HOST': cog_mqtt_host, 'ERL_FLAGS': '-smp enable'}) %}
{%- set region = salt['pillar.get']('nomad:region', 'us') %}
{%- set dc = salt['pillar.get']('nomad:datacenter', 'dc') %}
{%- set cmd = 'scripts/wait-for-it.sh -s -t 0 -h ' ~ cog_mqtt_host ~ ' -p 1883 -- elixir --no-halt --name relay@' ~ hostname ~ ' -S mix' %}
{%- set volumes = { data_dir: '/home/operable/relay/data'} %}
{%- set ports = [] %}


cog-relay-data-dir:
  file.directory:
    - name: {{ data_dir }}
    - user: ubuntu
    - group: ubuntu
    - mode: 750

cog-relay-exec-wrapper:
  file.managed:
    - name: /usr/local/bin/start-cog-relay
    - user: root
    - mode: 755
    - contents: |
        #!/usr/bin/env python
        import sys
        from docker import Client
        cli = Client(base_url='unix://var/run/docker.sock')
        cli.containers()
        repo = '{{ docker_repo }}'
        tag = '{{ docker_tag }}'
        image = '%s:%s' % (repo, tag)
        service_name = '{{ cname }}'
        ip = '{{ ip }}'
        volume_mounts = [{% for k,v in volumes.items() %}'{{ k }}:{{ v }}', {% endfor %}]
        port_bindings = { {% for p in ports %}{{ p }}: ( '{{ ip }}', {{ p }} ), {% endfor %} }
        port_list = [{% for p in ports %}{{ p }}, {% endfor %}]
        host_config = cli.create_host_config(binds=volume_mounts,
                                             port_bindings=port_bindings)
        env = { {%- for k,v in envvars.items() %}
                  '{{ k }}': '{{ v }}',
                {%- endfor %}
        }
        cmd = '{{ cmd }}'
        print 'attempt to pull %s' % image
        try: cli.pull(repository=repo, tag=tag, stream=False)
        except: sys.exit()
        print 'attempt to stop a running container/instance, if it exists'
        try: cli.stop(service_name)
        except: print 'skip stop, running container not found'
        print 'attempt to remove an existing container, if it exists'
        try: cli.remove_container(container=service_name, force=True)
        except: print 'skip rm, existing/old container not found'
        print 'attempt to create a new container..'
        container = cli.create_container(image=image, detach=True, name=service_name,
                                         ports=port_list, environment=env,
                                         host_config=host_config, entrypoint=cmd)
        print 'created %s' % container
        id=container.get('Id')
        print 'attempt to start that container (%s)' % id
        cli.start(container=id, network_mode='host')
        print 'retrieve and print stdout/err...'
        for msg in cli.logs(container=service_name, stream=True, stdout=True, stderr=True):
            print msg


cog-relay-nomad-job-config:
  file.managed:
    - name: /root/cog-relay.job
    - user: root
    - mode: 600
    - contents: |
        # Define a job called my-service
        job "cog-relay" {
            # Job should run in the US region
            region = "{{ region }}"
        
            # Spread tasks between us-west-1 and us-east-1
            datacenters = ["{{ dc }}"]
        
            type = "system"
        
            # Rolling updates should be sequential
        #   update {
        #       stagger = "30s"
        #       max_parallel = 1
        #   }
        
            # Create a web front end using a docker image
            task "cog-relay" {
        
                driver = "raw_exec"
                config {
                    command = "/usr/local/bin/start-cog-relay"
                }
                service {
                    name = "cog-relay"
                    tags = ["cog-relay"]
                }
                resources {
                    cpu = 50
        #           memory = 256
        #           network { }
                }
            }
        }
  cmd.run:
    - name: nomad run /root/cog-relay.job
    - require:
        - file: cog-relay-nomad-job-config
        - file: cog-relay-exec-wrapper
        - file: cog-relay-data-dir
