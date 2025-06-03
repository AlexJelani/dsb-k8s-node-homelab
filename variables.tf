variable "tenancy_ocid" {
  type        = string
  description = "The OCID of the tenancy."
  sensitive   = true
}

variable "user_ocid" {
  type        = string
  description = "The OCID of the user."
  sensitive   = true
}

variable "fingerprint" {
  type        = string
  description = "The fingerprint of the API key."
  sensitive   = true
}

variable "private_key_path" {
  type        = string
  description = "The path to the OCI API private key."
  sensitive   = true
}

variable "region" {
  type        = string
  description = "The OCI region to deploy resources in."
}

variable "compartment_ocid" {
  type        = string
  description = "The OCID of the compartment to deploy resources in."
}

variable "ssh_public_key" {
  type        = string
  description = "The public SSH key to authorize for instance access."
  # This is a public key, so arguably not sensitive, but often managed with care.
  # sensitive = false by default
}

variable "vcn_cidr_block" {
  description = "The CIDR block for the VCN."
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr_block" {
  description = "The CIDR block for the subnet."
  type        = string
  default     = "10.0.1.0/24"
}

variable "ssh_source_cidr" {
  description = "CIDR block allowed for SSH access to the node."
  type        = string
  default     = "0.0.0.0/0" # WARNING: Change this to your specific IP or a trusted range
}