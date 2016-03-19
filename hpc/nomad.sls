{%- set redis_host = salt['pillar.get']('hpc_manager:redis_host', 'localhost') %}
{%- set repo = salt['pillar.get']('hpc_manager:image', 'fpco/hpc-manager-ui') %}
{%- set region = salt['pillar.get']('nomad:region', 'us') %}
{%- set dc = salt['pillar.get']('nomad:datacenter', 'dc') %}

hpc-manager-exec-wrapper:
  file.managed:
    - name: /usr/local/bin/start-hpc-ui
    - user: root
    - mode: 755
    - contents: |
        #!/usr/bin/env python
        import sys
        from docker import Client
        cli = Client(base_url='unix://var/run/docker.sock')
        cli.containers()
        repo = '{{ repo|trim }}'
        tag = 'latest'
        image = '%s:%s' % (repo, tag)
        service_name = 'hpc-manager'
        workdir = '/usr/local/lib/hpc-manager/'
        port_config = cli.create_host_config(port_bindings={3000: ('127.0.0.1',3000)})
        env = {'HPC_REDIS_HOST': '{{ redis_host|trim }}',
               'HPC_REDIS_PREFIX': 'hmst.simulator'}
        cmd = 'hpc-manager'
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
                                         working_dir=workdir, ports=[3000], environment=env,
                                         host_config=port_config, command=cmd)
        print 'created %s' % container
        id=container.get('Id')
        print 'attempt to start that container (%s)' % id
        cli.start(container=id)
        print 'retrieve and print stdout/err...'
        for msg in cli.logs(container=service_name, stream=True, stdout=True, stderr=True):
            print msg 


hpc-ui-nomad-job-config:
  file.managed:
    - name: /root/hpc-ui.job
    - user: root
    - mode: 600
    - contents: |
        # Define a job called my-service
        job "hpc-ui" {
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
            task "hpc-ui" {
                # We want 1 hpc-ui
                count = 1
        
                driver = "raw_exec"
                config {
                    command = "/usr/local/bin/start-hpc-ui"
                }
                service {
                    name = "hpc-ui"
                    tags = ["hpc-ui"]
                }
                resources {
                    cpu = 50
        #           memory = 256
                    network { }
                }
            }
        }
  cmd.run:
    - name: nomad run /root/hpc-ui.job
    - require:
        - file: hpc-ui-nomad-job-config
        - file: hpc-manager-exec-wrapper
