{%- set region = salt['pillar.get']('nomad:region', 'us') %}
{%- set dc = salt['pillar.get']('nomad:datacenter', 'dc') %}

fabio-nomad-job-config:
  file.managed:
    - name: /root/fabio.job
    - user: root
    - mode: 600
    - contents: |
        job "fabio" {
            region = "{{ region }}"
            datacenters = ["{{ dc }}"]
            type = "service"
            group "load_balancers" {
                count = 1
                task "fabio" {
        
                    driver = "docker"
                    config {
                        image = "magiconair/fabio"
                        network_mode = "host"
                        port_map {
                            fabio = 9997
                            ui = 9998
                        }
                    }
                    service {
                        name = "lb"
                        tags = ["lb", "ui"]
                        port = "ui"
                        check {
                            type = "http"
                            path = "/"
                            interval = "30s"
                            timeout = "1s"
                        }
                    }
                    resources {
                        cpu = 50
                        memory = 256
                        network {
                            mbits = 100
                            port "lb" {
                                static = 9997
                            }
                            port "ui" {
                                static = 9998
                            }
                        }
                    }
                }
            }
        }

  cmd.run:
    - name: nomad run /root/fabio.job
    - require:
        - file: fabio-nomad-job-config
