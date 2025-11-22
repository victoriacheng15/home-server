terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

module "postgres" {
  source = "./modules/postgres-local"

  postgres_super_password = var.postgres_super_password
  app_db_password         = var.app_db_password
}