resource "aws_db_instance" "postgres" {
  identifier          = "rds-llm-test"
  engine              = "postgres"
  engine_version      = "15"
  instance_class      = "db.t3.micro"
  allocated_storage   = 20
  db_name             = "appdb"
  username            = "admin"
  password            = "changeme"
  skip_final_snapshot = true
}
