{%- set image = 'docker.fpcomplete.com/stackage:latest' %}
{%- set tag = 'latest' %}

include:
  - docker.install
  - stackage.server.user

stackage-image:
  docker.pulled:
    - name: {{ image }}
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
