resource "aws_db_instance" "clixx-retail-app" {
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  instance_class         = "db.t2.micro"
  identifier             = locals.db_creds.DB_NAME
  username               = locals.db_creds.DB_USER
  password               = locals.db_creds.DB_PASSWORD
  parameter_group_name   = "default.mysql8.0"
  skip_final_snapshot    = true
  snapshot_identifier    = var.shared_snapshot_arn
  multi_az               = true
  vpc_security_group_ids = [aws_security_group.clixx-app-mysql.id]
  db_subnet_group_name = aws_db_subnet_group.clixx_db_subnet_group.name
}
