resource "aws_security_group" "stack-sg" {
  #  vpc_id = var.vpc
  name        = "Stack-WebDMZ"
  description = "Stack IT Security Group For CliXX System"
}

resource "aws_security_group_rule" "ssh" {
  security_group_id = aws_security_group.stack-sg.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "https" {
  security_group_id = aws_security_group.stack-sg.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "http" {
  security_group_id = aws_security_group.stack-sg.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "nfs" {
  security_group_id = aws_security_group.stack-sg.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 2049
  to_port           = 2049
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "mysql_aurora" {
  security_group_id = aws_security_group.stack-sg.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 3306
  to_port           = 3306
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "clixx-app-egress" {
  security_group_id = aws_security_group.stack-sg.id
  type              = "egress"
  protocol          = "-1" # Allow all protocols
  from_port         = 0    # Start from port 0
  to_port           = 0    # This will effectively allows all ports
  cidr_blocks       = ["0.0.0.0/0"]
}