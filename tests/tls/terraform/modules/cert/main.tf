variable "private_key_algo" {
  default     = "RSA"
  description = "Cryptographic algorithm to use when generating the root private key"
  type        = string
}

variable "private_key_ecdsa_curve" {
  default     = ""
  description = "Only applicable when private_key_algo is 'ECDSA', sets the ECDSA curve to use for that algorithm"
  type        = string
}

variable "ca_key_algorithm" {
  default     = "RSA"
  description = "The algorithm used to generate the CA's private key"
  type        = string
}

variable "ca_private_key_pem" {
  description = "The CA's private (PEM formatted)"
  type        = string
}

variable "ca_cert_pem" {
  description = "The CA's certificate (PEM formatted)"
  type        = string
}

variable "allowed_uses" {
  default     = ["server_auth"]
  description = "List of 'allowed uses' for the service's new certificate"
  type        = list(string)
}

####

locals {
  # the root cert is valid for this period, and must be renewed before then
  validity_period_hours = 26280

  # create a new root cert before the original expires
  early_renewal_hours = 8760

  # info for the certificate
  subject = {
    common_name         = "Example Inc. Root"
    organization        = "Example, Inc"
    organizational_unit = "Department of Certificate Authority"
    street_address      = ["5879 Cotton Link"]
    locality            = "Pirate Harbor"
    province            = "CA"
    country             = "US"
    postal_code         = "95559-1227"
  }
}

resource "tls_private_key" "service" {
  algorithm   = var.private_key_algo
  ecdsa_curve = var.private_key_ecdsa_curve
}

resource "tls_cert_request" "service" {
  key_algorithm   = tls_private_key.service.algorithm
  private_key_pem = tls_private_key.service.private_key_pem

  subject {
    common_name = "*.example.net"
    organization = "Example, Inc"
    organizational_unit = "Tech Ops Dept"
  }
}

resource "tls_locally_signed_cert" "service" {
  cert_request_pem = tls_cert_request.service.cert_request_pem

  ca_key_algorithm   = var.ca_key_algorithm
  ca_private_key_pem = var.ca_private_key_pem
  ca_cert_pem        = var.ca_cert_pem

  # define cert validation and renewal
  validity_period_hours = local.validity_period_hours
  early_renewal_hours   = local.early_renewal_hours

  allowed_uses = var.allowed_uses
}

output "cert_pem" {
  description = "The service's new certificate, PEM formatted"
  value       = tls_locally_signed_cert.service.cert_pem
}

