resource "local_file" "init_sql" {
  content  = templatefile("${path.module}/initdb/01-create-app-user.sql.tpl", {
    APP_DB_PASSWORD = var.app_db_password
  })
  filename = "${path.module}/initdb/01-create-app-user.sql"
}

resource "null_resource" "postgres_deploy" {
  depends_on = [local_file.init_sql]

  triggers = {
    compose_hash = filesha1("${path.module}/../../../docker-compose.yml")
    init_tpl_hash = filesha1("${path.module}/initdb/01-create-app-user.sql.tpl")
  }

  provisioner "local-exec" {
    command = "./deploy.sh"
    environment = {
      POSTGRES_SUPER_PASS = var.postgres_super_password
    }
    working_dir = path.module
  }

  provisioner "local-exec" {
    when    = destroy
    command = "cd ${path.module}/../../.. && docker compose down postgres"
  }
}