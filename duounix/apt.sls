duo-apt:
  pkgrepo.managed:
    - name: 'deb http://pkg.duosecurity.com/Ubuntu trusty main'
    - humanname: 'DUO Apt Repo'
    - file: '/etc/apt/sources.list.d/duounix.list'
    - key_url: https://www.duosecurity.com/APT-GPG-KEY-DUO
