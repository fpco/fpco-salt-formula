module "tls-certificate-authority" {
  source = "./modules/ca-self-signed"

}

module "my-servivce-cert" {
  source = "./modules/cert"

  ca_private_key_pem = module.tls-certificate-authority.private_key_pem
  ca_cert_pem        = module.tls-certificate-authority.cert_pem
}

resource "local_file" "my_service_cert_pem" {
  filename          = "./my-service-cert.pem"
  sensitive_content = module.my-servivce-cert.cert_pem
}
