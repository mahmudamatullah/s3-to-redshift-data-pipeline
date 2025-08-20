variable "redshift_username" {
  type        = string
}

variable "redshift_password" {
  type        = string
  sensitive   = true
}
