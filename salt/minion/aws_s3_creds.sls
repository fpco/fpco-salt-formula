{%- set key = salt['pillar.get']('aws:s3:key', '') %}
{%- set secret = salt['pillar.get']('aws:s3:secret', '') %}

salt-minion-s3-creds:
  file.managed:
    - name: /etc/salt/minion.d/s3.conf
    - user: root
    - group: root
    - mode: 640
    - contents: |
        s3.keyid: {{ key }}
        s3.key: {{ secret }}
