{%- set default_cron_id = 'CONSUL_BACKUP' %}
{%- set cron_id     = salt['pillar.get']('consul_backup:cron:id', default_cron_id) %}
{%- set cron_minute = salt['pillar.get']('consul_backup:cron:minute', '0') %}
{%- set cron_hour   = salt['pillar.get']('consul_backup:cron:hour', '*') %}
{%- set cron_dom    = salt['pillar.get']('consul_backup:cron:dom', '*') %}
{%- set cron_month  = salt['pillar.get']('consul_backup:cron:month', '*') %}
{%- set cron_dow    = salt['pillar.get']('consul_backup:cron:dow', '*') %}
{%- set s3_bucket   = salt['pillar.get']('consul_backup:s3:bucket') %}
{%- set s3_path     = salt['pillar.get']('consul_backup:s3:path', 'consul') %}
{%- set s3_profile  = salt['pillar.get']('consul_backup:s3:profile', 'default') %}
{%- set user        = salt['pillar.get']('consul_backup:user', 'consul') %}

{%- set default_exec_path = '/usr/local/bin/backup-consul.sh' %}
{%- set exec_path = salt['pillar.get']('consul_backup:exec_path', default_exec_path) %}

{%- set default_local_path = '/home/consul/backup' %}
{%- set local_backup_path = salt['pillar.get']('consul_backup:path', default_local_path) %}


consul-backup-path:
  file.directory:
    - name: {{ local_backup_path }}
    - user: {{ user }}
    - group: root
    - mode: 750
    - makedirs: True


consul-backup-exec:
  file.managed:
    - name: {{ exec_path }}
    - user: {{ user }}
    - group: root
    - mode: 550
    - contents: |
        #!/bin/sh
        PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/bin

        ### Config
        NOW=$(date +"%Y%m%d_%H%M%S" -u)
        BACKUP_DIR={{ local_backup_path }}
        BACKUP_FILE="$NOW.xz"
        LOCAL_BACKUP_PATH=$BACKUP_DIR/$BACKUP_FILE
        AWS_PROFILE="{{ s3_profile }}"
        S3_BASE_URL="s3://{{ s3_bucket }}/{{ s3_path }}"
        S3_URL="$S3_BASE_URL/$BACKUP_FILE"

        ### Exec
        echo "Backup Consul KV at $NOW"
        echo "Backup Dir: $BACKUP_DIR"
        echo "Dumping Consul KV to $LOCAL_BACKUP_PATH"
        consulkv dump | xz > $LOCAL_BACKUP_PATH
        echo "Moving $LOCAL_BACKUP_PATH to $S3_URL"
        aws s3 mv $LOCAL_BACKUP_PATH $S3_URL --profile $AWS_PROFILE
        echo "ls the remote URL:"
        aws s3 ls $S3_URL --profile $AWS_PROFILE
        echo "Backup complete!"

  cron.present:
    - name: {{ exec_path }}
    - identifier: {{ cron_id }}
    - user: {{ user }}
    - minute: '{{ cron_minute }}'
    - hour: '{{ cron_hour }}'
    - daymonth: '{{ cron_dom }}'
    - month: '{{ cron_month }}'
    - dayweek: '{{ cron_dow }}'
    - comment: "Automated backup for the consul KV datastore"
    - require:
        - file: consul-backup-path
        - file: consul-backup-exec

