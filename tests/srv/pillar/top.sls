base:
  'ubuntu-xenial':
    - bootstrap-single
    - credstash

  'leader-*':
    - bootstrap-leaders

  'worker-*':
    - bootstrap-workers
