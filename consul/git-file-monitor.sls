{%- set img = salt['pillar.get']('git-file-monitor:image', 'docker-registry.amgencss.fpcomplete.com/fpco/dev-tools') %}
{%- set tag = salt['pillar.get']('git-file-monitor:tag', 'latest') %}
{%- set cname = 'git-file-monitor' %}


{{ cname }}-upstart:
  file.managed:
    - name: /etc/init/{{ cname }}.conf
    - user: root
    - group: root
    - mode: 644
    - source: salt://docker/files/upstart-tpl-container-as-a-service.sls
    - template: jinja
    - context:
        desc: 'Monitor git, load settings into consul on change'
        author: the-ops-ninjas@fpcomplete.com
        container_name: {{ cname }}
        # the Docker image to use
        img: {{ img }}
        # the image tag to reference
        tag: {{ tag }}
        cmd: '/git-file-monitor.yml'
        docker_args:
          - '--volume /home/consul/git-file-monitor.yaml:/git-file-monitor.yml'
          - '--entrypoint /usr/local/bin/git-file-monitor'
  service.running:
    - name: {{ cname }}
    - enable: True
    - watch:
        - file: {{ cname }}-upstart


{{ cname }}-config:
  file.managed:
    - name: /home/consul/git-file-monitor.yaml
    - user: consul
    - group: root
    - mode: 640
    - contents_pillar: git-file-monitor:config
    - watch_in:
        - service: {{ cname }}-upstart
