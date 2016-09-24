# install_from_docker:
#   docker.example.com/fpco/dev-tools:
#     - /usr/local/bin/git-file-monitor
#     - /usr/local/bin/snap-ebs
#
# this magic sequence is used to "install" executables from docker images
# onto a path on the host system, making it available outside docker
{%- set docker_images = salt['pillar.get']('install_from_docker', {}) %}
{%- set copy_to = '/usr/local/bin/' %}

{%- for img, to_install in docker_images.items() %}
  {%- set pull_image = 'docker pull ' ~ img %}

pull-src-image-{{ img }}:
  cmd.run:
    - name: "{{ pull_image }}"

  {%- for executable in to_install %}
  {%- set create_container = 'docker run --name tmp ' ~ img ~ ' true' %}
  {%- set local_path = copy_to ~ '`basename ' ~ executable ~ '`' %}
  {%- set copy_executable = 'docker cp tmp:' ~ executable ~ ' ' ~ local_path %}
  {%- set remove_container = 'docker rm tmp' %}
  {%- set install_bin = create_container ~ ' && ' ~ copy_executable ~ ' && ' ~ remove_container %}

install-from-docker-{{ executable }}:
  cmd.run:
    - name: "{{ install_bin }}"
    - unless: {{ executable }}
    - require:
        - cmd: pull-src-image-{{ img }}

test-{{ executable }}:
  cmd.run:
    - name: "{{ executable }} --version"
    - require:
        - cmd: install-from-docker-{{ executable }}
  {%- endfor %}

{%- endfor %}
