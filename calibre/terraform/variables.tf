variable "domain_name" {
  description = "FQDN for Calibre-Web (subdomain)"
  default     = "cweb.chord-memory.net"
  type        = string
}

variable "hosted_zone_id" {
  description = "Route53 hosted zone ID for chord-memory.net"
  default     = "Z05075933Q3K3AU5833WD"
  type        = string
}

variable "setup_path" {
  description = "Relative location of setup files"
  default     = "../setup"
  type        = string
}

variable "library_bucket_name" {
  default = "cweb-library"
  type    = string
}

variable "setup_bucket_name" {
  default = "cweb-setup"
  type    = string
}

variable "config_volume_device_mnt" {
  default = "/dev/sdf"
  type    = string
}

variable "library_volume_device_mnt" {
  default = "/dev/sdg"
  type    = string
}

variable "config_volume_size_gb" {
  default = 4
  type    = number
}

variable "library_volume_size_gb" {
  default = 8
  type    = number
}

variable "admin_email" {
  description = "Used for Caddy logs/emails"
  default     = "jordancahill88@gmail.com"
  type        = string
}

variable "admin_user" {
  description = "Calibre-Web UI creds"
  default     = "admin"
  type        = string
}

variable "admin_pass" {
  description = "Calibre-Web UI creds"
  type        = string
}