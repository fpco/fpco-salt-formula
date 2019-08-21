job "hashi-ui" {
  region      = "us"
  datacenters = ["vagrant"]
  type        = "service"
  priority    = 60

  group "server" {
    count = 1

    task "hashi-ui" {
      driver = "docker"

      config {
        image        = "jippi/hashi-ui"
        network_mode = "host"
        }

      #constraint {
      #  attribute = "${node.class}"
      #  operator  = "="
      #  value     = "managers"
      #}

      service {
        port = "http"

        check {
          type     = "http"
          path     = "/_status"
          interval = "10s"
          timeout  = "2s"
        }

        tags = [
          "urlprefix-/hashi-ui"
        ]
      }

      env {
        CONSUL_ENABLE = 1
        CONSUL_ADDR = "http://consul.service.local:8500"
        NOMAD_ENABLE = 1
        NOMAD_ADDR   = "http://http.nomad.service.local:4646"
        #PROXY_ADDRESS = "localhost:3000/hashi-ui"
        PROXY_ADDRESS = "localhost:3000"
      }

      resources {
        cpu    = 250
        memory = 96

        network {
          mbits = 3

          port "http" {
            static = 3000
          }
        }
      }
    }
  }
}
