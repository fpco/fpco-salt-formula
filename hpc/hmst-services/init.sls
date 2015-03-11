hmst-services:
  file.managed:
    - name: /etc/init/hmst-services.conf
    - mode: 640
    - user: root
    - group: root
    - source: salt://hpc/hmst-services/files/upstart.conf
    - template: jinja
    - defaults:
        bin_path: /usr/local/bin/hmst-services
        cwd: /usr/local/lib/hmst-services
        run_as_user: 'ubuntu'
        port: 8000
        redis_host: 10.200.10.180
  service.running:
    - name: hmst-services
    - watch:
        - file: hmst-services
        - file: hmst-services-executable
        - file: hmst-services-config


hmst-services-executable:
  file.managed:
    - name: /usr/local/bin/hmst-services
    - mode: 755
    - user: root
    - group: root
    - source: salt://hpc/hmst-services/files/services


hmst-services-config:
  file.recurse:
    - name: /usr/local/lib/hmst-services/config
    - dir_mode: 2755
    - file_mode: 640
    - user: ubuntu
    - group: ubuntu
    - source: salt://hpc/hmst-services/files/config/


hmst-services-static:
  file.recurse:
    - name: /usr/local/lib/hmst-services/static
    - dir_mode: 2755
    - file_mode: 640
    - user: ubuntu
    - group: ubuntu
    - source: salt://hpc/hmst-services/files/static/
