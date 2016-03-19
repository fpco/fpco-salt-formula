{%- set cname = 'cog-master' %}
{%- set docker_repo = 'operable/cog' %}
{%- set docker_tag = 'latest' %}
{%- set ip = salt['grains.get']('ip4_interfaces')['eth0'][0] %}
{%- set hostname = salt['grains.get']('id') %}
{%- set data_dir = '/var/lib/cog-master' %}
{%- set envvars = salt['pillar.get']('cog:master:envvars', {}) %}
{%- set pg_user = salt['pillar.get']('cog:master:pg_user', 'cog') %}
{%- set pg_pass = salt['pillar.get']('cog:master:pg_pass', 'cog') %}
{%- set pg_host = salt['pillar.get']('cog:master:pg_host', 'postgres') %}
{%- set pg_url = 'ecto://' ~ pg_user ~ ':' ~ pg_pass ~ '@' ~ pg_host ~ ':5432/cog' %}
{%- do envvars.update({'DATABASE_URL': pg_url,
                       'ERL_FLAGS': '-smp enable'}) %}
{%- set region = salt['pillar.get']('nomad:region', 'us') %}
{%- set dc = salt['pillar.get']('nomad:datacenter', 'dc') %}
{%- set cmd = 'scripts/wait-for-it.sh -s -t 0 -h ' ~ pg_host ~ ' -p 5432 -- elixir --no-halt --name cog@' ~ hostname ~ ' --no-halt -S mix do ecto.create, ecto.migrate, phoenix.server' %}
{%- set volumes = { data_dir: '/home/operable/cog/data'} %}
{%- set ports = [1883,4000] %}


cog-relay-data-dir:
  file.directory:
    - name: {{ data_dir }}
    - user: ubuntu
    - group: ubuntu
    - mode: 750

cog-master-exec-wrapper:
  file.managed:
    - name: /usr/local/bin/start-cog-master
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


cog-master-nomad-job-config:
  file.managed:
    - name: /root/cog-master.job
    - user: root
    - mode: 600
    - contents: |
        # Define a job called my-service
        job "cog-master" {
            # Job should run in the US region
            region = "{{ region }}"
        
            # Spread tasks between us-west-1 and us-east-1
            datacenters = ["{{ dc }}"]
        
            type = "service"
        
            # Rolling updates should be sequential
        #   update {
        #       stagger = "30s"
        #       max_parallel = 1
        #   }
        
            # Create a web front end using a docker image
            task "cog-master" {
        
                driver = "raw_exec"
                config {
                    command = "/usr/local/bin/start-cog-master"
                }
                service {
                    name = "cog-master"
                    tags = ["cog-master"]
                }
                resources {
                    cpu = 50
        #           memory = 256
        #           network { }
                }
            }
        }
  cmd.run:
    - name: nomad run /root/cog-master.job
    - require:
        - file: cog-master-nomad-job-config
        - file: cog-master-exec-wrapper
