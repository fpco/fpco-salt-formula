{%- set image = 'docker.fpcomplete.com/stackage:latest' %}
{%- set tag = 'latest' %}
{%- set force = True %}

include:
  - docker.install
  - stackage.server.user

stackage-image:
  docker.pulled:
    - name: {{ image }}
    - force: {{ force }}
    - require:
        - service: docker

# extend the existing stackage user definition from stackage.server.config,
# ensure the stackage user is in the docker group
extend:
  stackage:
    user.present:
      - groups:
          - docker
      - require:
          - group: docker
