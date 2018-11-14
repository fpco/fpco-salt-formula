job "fabio" {
  region      = "us"
  datacenters = ["vagrant"]
  type        = "system"

  group "fabio" {
    count = 1

    task "server" {
      driver = "exec"

      artifact {
        source      = "https://github.com/fabiolb/fabio/releases/download/v1.5.9/fabio-1.5.9-go1.10.2-linux_amd64"
        destination = "local/"

        options {
          checksum = "sha256:bba27283a09f6473f5e9781a1a30d8fdd9b45912b6c977949fcc8fd8e0ea4763"
        }
      }

      config {
        command = "local/fabio-1.5.9-go1.10.2-linux_amd64"

        args = [
          "-cfg", "local/fabio.properties",
          "-proxy.addr", "${NOMAD_ADDR_https};cs=fabio"
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
          mbits = 100

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
proxy.cs = cs=fabio;type=vault;cert=secret/fabio/certs
registry.consul.addr = consul.service.local:8500
        EOH

        destination = "local/fabio.properties"
      }

      vault {
        policies = ["fabio-secrets"]
      }

    }
  }
}
