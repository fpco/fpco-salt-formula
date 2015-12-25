include:
  - consul.service

salt-minion-consul:
  file.managed:
    - name: /home/consul/conf.d/salt_master_watch.json
    - user: consul
    - group: consul
    - mode: 640
    - contents: |
        {
            "watches": [
                {
                  "type": "service",
                  "service": "salt-master",
                  "passingonly": true,
                  "handler": "sudo service salt-minion restart"
                }
            ]
        }
    - watch_in:
        - service: consul-upstart
