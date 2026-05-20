resource "aws_db_instance" "postgres" {
  identifier        = "${var.project_name}-${var.environment}"
  engine            = "postgres"
  engine_version    = "15.4"
  instance_class    = var.db_instance_class
  allocated_storage = var.db_allocated_storage
  storage_type      = "gp3"
  storage_encrypted = true

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password
  port     = 5432

  db_subnet_group_name   = aws_db_subnet_group.rds.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  publicly_accessible     = false
  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "Mon:04:00-Mon:05:00"

  deletion_protection = false
  skip_final_snapshot = true

  tags = {
    Name        = "${var.project_name}-postgres"
    Environment = var.environment
  }
}

resource "aws_secretsmanager_secret" "rds_url" {
  name                    = "${var.project_name}/${var.environment}/rds-url"
  recovery_window_in_days = 0

  tags = {
    Name        = "${var.project_name}-rds-url"
    Environment = var.environment
  }
}

resource "aws_secretsmanager_secret_version" "rds_url" {
  secret_id = aws_secretsmanager_secret.rds_url.id
  secret_string = jsonencode({
    RDS_URL = "postgresql+psycopg2://${var.db_username}:${var.db_password}@${aws_db_instance.postgres.endpoint}/${var.db_name}"
  })
}
