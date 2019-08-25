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

variable "cert_algo" {
  default     = "RSA"
  description = "Cryptographic algorithm to use when generating the root certificate"
  type        = string
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

####

# Private Key for our Root CA
resource "tls_private_key" "root" {
  algorithm   = var.private_key_algo
  ecdsa_curve = var.private_key_ecdsa_curve
}

# Certificate for our Root CA (signed by Private Key)
resource "tls_self_signed_cert" "root" {
  key_algorithm   = var.cert_algo
  private_key_pem = tls_private_key.root.private_key_pem

  # define cert validation and renewal
  validity_period_hours = local.validity_period_hours
  early_renewal_hours   = local.early_renewal_hours

  # required for being a "CA" and signing other certs that could be accepted by a browser
  is_ca_certificate = true
  allowed_uses      = ["cert_signing"]

  # dictionary with client org info (common name, org, address, etc)
  subject { 
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

output "cert_pem" {
  description = "The CA's root certificate, PEM formatted"
  value       = tls_self_signed_cert.root.cert_pem
}

output "private_key_pem" {
  description = "The private portion of the CA's root key, PEM formatted"
  value       = tls_private_key.root.private_key_pem
}

output "public_key_pem" {
  description = "The public portion of the CA's root key, PEM formatted"
  value       = tls_private_key.root.public_key_pem
}

