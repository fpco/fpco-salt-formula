base:
  'ubuntu-xenial':
    - bootstrap-single
    - credstash

  'leaders-*':
    - bootstrap-leaders

  'workers-*':
    - bootstrap-workers
