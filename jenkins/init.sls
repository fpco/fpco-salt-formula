{%- set jenkins = pillar.get('jenkins', {}) %}
{%- set home = jenkins.get('home', '/srv/jenkins') %}
{%- set user = jenkins.get('user', 'jenkins') %}
{%- set group = jenkins.get('group', user) %}


jenkins:
  group.present:
    - name: {{ group }}
  user.present:
    - name: {{ user }}
    - groups:
        - {{ group }}
    - require:
        - group: jenkins
  file.directory:
    - name: {{ home }}
    - user: {{ user }}
    - group: {{ group }}
    - mode: 0755
    - require:
        - user: jenkins
        - group: jenkins
  pkgrepo.managed:
    - humanname: Jenkins upstream package repository
    - name: deb http://pkg.jenkins-ci.org/debian binary/
    - key_url: http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key
    - require_in:
        - pkg: jenkins
  pkg.latest:
    - refresh: True
  service.running:
    - enable: True
    - watch:
        - pkg: jenkins
    - require:
        - file: jenkins


jenkins-firewall:
  file.managed:
    - name: /etc/ufw/applications.d/jenkins
    - user: root
    - group: root
    - mode: 640
    - contents: |
        [jenkins]
        title=Jenkins Web UI
        description=Open port 8080 for the Web UI
        ports=8080/tcp
  cmd.run:
    - name: 'ufw allow jenkins'
    - require:
        - file: jenkins-firewall
