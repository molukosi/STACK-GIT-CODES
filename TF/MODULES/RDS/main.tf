resource "aws_db_instance" "clixx-retail-app" {
  instance_class         = var.instance_class
  identifier             = var.DB_NAME
  username               = var.DB_USER
  password               = var.DB_PASSWORD
  parameter_group_name   = var.parameter_group_name
  skip_final_snapshot    = var.skip_final_snapshot
  snapshot_identifier    = var.snapshot_identifier
  vpc_security_group_ids = [var.sg_info_existing]

  tags = merge(var.required_tags, {"Name"="var.DB_NAME"})

}