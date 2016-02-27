# manages the configuration file for logging in the SDK
newrelic-sdk-log-config:
  file.managed:
    - name: /etc/newrelic/sdk_log4cplus.cfg
    - user: newrelic
    - group: newrelic
    # the SDK would run in an app that might run as another user
    - mode: 644
    - source: salt://newrelic/files/sdk_log4cplus.cfg

newrelic-sdk-log-envvar:
  file.append:
    - name: /etc/environment
    - text: NEWRELIC_LOG_PROPERTIES_FILE=/etc/newrelic/sdk_log4cplus.cfg
