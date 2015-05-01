backend "{{ backend }}" {
    "path" = "{{ path }}"
}

listener "tcp" {
    tls_cert_file = "{{ cert_file }}"
    tls_key_file  = "{{ key_file }}"
}
