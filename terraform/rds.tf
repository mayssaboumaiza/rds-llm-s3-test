resource "aws_db_instance" "postgres" {
  identifier          = "${var.project_name}-${var.environment}"
  engine              = "postgres"
  engine_version      = "15"
  instance_class      = var.db_instance_class
  allocated_storage   = var.db_allocated_storage
  db_name             = var.db_name
  username            = var.db_username
  password            = var.db_password
  skip_final_snapshot = true

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}
