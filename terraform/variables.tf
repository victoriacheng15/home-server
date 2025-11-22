variable "postgres_super_password" {
  description = "Superuser password (for init only)"
  type        = string
  sensitive   = true
}

variable "app_db_password" {
  description = "Password for 'server' app user"
  type        = string
  sensitive   = true
}