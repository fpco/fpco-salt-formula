job "fabio" {
  region      = "us"
  datacenters = ["vagrant"]
  type        = "system"

  group "fabio" {
    count = 1

    task "server" {
      driver = "exec"

      artifact {
        source      = "https://github.com/fabiolb/fabio/releases/download/v1.5.11/fabio-1.5.11-go1.11.5-linux_amd64"
        destination = "local/"

        options {
          checksum = "sha256:8b00a6c67e8d43c38f7b3592d604d411f907745c6d55bb7ac72910a9a951c979"
        }
      }

      config {
        command = "local/fabio-1.5.11-go1.11.5-linux_amd64"

        args = [
          "-cfg", "local/fabio.properties",
          "-proxy.addr", "${NOMAD_ADDR_https}" #;cs=fabio"
        ]
      }

      env {
        VAULT_ADDR = "http://vault.service.local:8200"
      }

      service {
        port = "https"

        check {
          type     = "tcp"
          interval = "30s"
          timeout  = "5s"
        }
      }

      resources {
        cpu    = 500
        memory = 512

        network {
          mbits = 10

          port "https" {
            static = 9999
          }

          port "admin" {
            static = 9998
          }
        }
      }

      template {
        data = <<EOH
#proxy.cs = cs=fabio;type=vault;cert=secret/fabio/certs
registry.consul.addr = consul.service.local:8500
        EOH

        destination = "local/fabio.properties"
      }

#     vault {
#       policies = ["fabio-secrets"]
#     }

    }
  }
}
