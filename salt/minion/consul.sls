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
                  "handler": "salt-call --local state.sls salt.minion.base"
                }
            ]
        }
    - watch_in:
        - service: consul-upstart
