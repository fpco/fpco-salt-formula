# Run the Prometheus Docker image as a service
#
# More details are documented in pillar:
{%- set image = salt['pillar.get']('prometheus:image', 'prom/prometheus') %}
{%- set tag = salt['pillar.get']('prometheus:tag', 'latest') %}
{%- set port = salt['pillar.get']('prometheus:port', '9090') %}
{%- set home = salt['pillar.get']('prometheus:home', '/prometheus') %}

{%- set cname = 'prometheus' %}

prometheus-config:
  file.managed:
    - name: /etc/prometheus.yml
    - user: root
    - group: root
    - mode: 644
    - contents: |
        # my global config
        global:
          scrape_interval:     15s # By default, scrape targets every 15 seconds.
          evaluation_interval: 15s # By default, scrape targets every 15 seconds.
          # scrape_timeout is set to the global default (10s).
        
          # Attach these extra labels to all timeseries collected by this Prometheus instance.
          labels:
              monitor: 'codelab-monitor'
        
        # Load and evaluate rules in this file every 'evaluation_interval' seconds.
        rule_files:
          # - "first.rules"
          # - "second.rules"
        
        # A scrape configuration containing exactly one endpoint to scrape: 
        # Here it's Prometheus itself.
        scrape_configs:
          # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
          - job_name: 'prometheus'
        
            # Override the global default and scrape targets from this job every 5 seconds.
            scrape_interval: 5s
            scrape_timeout: 10s
        
            # metrics_path defaults to '/metrics'
            # scheme defaults to 'http'.
        
            target_groups:
              - targets: ['localhost:9090']
              - targets: ['localhost:9100']


prometheus-upstart:
  file.managed:
    - name: /etc/init/{{ cname }}.conf
    - user: root
    - group: root
    - mode: 644
    - source: salt://docker/files/upstart-tpl-container-as-a-service.sls
    - template: jinja
    - context:
        desc: Prometheus Monitoring Service
        author: the-ops-ninjas@fpcomplete.com
        # the name of the container instance
        container_name: {{ cname }}
        # the Docker image to use
        img: {{ image }}
        # the image tag to reference
        tag: {{ tag }}
        # ip/port mapping
        docker_args:
          - '--publish 127.0.0.1:{{ port }}:9090'
          - '--volume /etc/prometheus.yml:/etc/prometheus/prometheus.yml'
          - '--volume {{ home }}:/prometheus-data'
    - require:
        - file: prometheus-config
  service.running:
    - name: prometheus
    - enable: True
    - watch:
        - file: prometheus-upstart
        - file: prometheus-config

