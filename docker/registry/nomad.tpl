# Define a job called docker-registry
job "docker-registry" {
    region = "{{ region }}"
    datacenters = ["{{ datacenter }}"]
    type = "service"
    task "docker-registry" {
        count = 1
        {%- raw %}
        env {
            REGISTRY_STORAGE_S3_ACCESSKEY = "{{ key "registry/accesskey" }}"
            REGISTRY_STORAGE_S3_SECRETKEY = "{{ key "registry/secretkey" }}"
            REGISTRY_STORAGE_S3_REGION = "{{ key "registry/region" }}"
            REGISTRY_STORAGE_S3_BUCKET = "{{ key "registry/bucket" }}"
            REGISTRY_STORAGE_S3_ENCRYPT = "true"
        }
        {%- endraw %}
        port "registry" {}
        driver = "docker"
        config {
            image = "registry:2"
            port_map {
                registry = 5000
            }
        }
        service {
            name = "docker-registry"
            tags = ["docker-registry"]
            port = "registry"
            check {
                type = "http"
                path = "/"
                interval = "30s"
                timeout = "1s"
            }
        }
        resources {
            cpu = 50
            memory = 256
            network {
                port "registry" {
                    static = 5000
                }
            }
        }
    }
}
