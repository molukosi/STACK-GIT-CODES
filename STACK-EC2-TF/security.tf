resource "aws_security_group" "clixx-app-loadbalancer" {
  name        = "Clixx app load balancer"
  description = "Load Balancer Security Group For CliXX App"
  vpc_id      = aws_vpc.clixx-app-vpc.id
  tags = {
    Name = "clixx-app-loadbalancer"
  }
}

resource "aws_security_group" "clixx-app-server" {
  name        = "Clixx app server"
  description = "App Server Security Group For CliXX App"
  vpc_id      = aws_vpc.clixx-app-vpc.id
  tags = {
    Name = "clixx-app-server"
  }
}

resource "aws_security_group" "clixx-bastion-server" {
  name        = "Clixx bastion server"
  description = "Bastion Server Security Group For CliXX App"
  vpc_id      = aws_vpc.clixx-app-vpc.id
  tags = {
    Name = "clixx-bastion-server"
  }
}

resource "aws_security_group" "clixx-app-mysql" {
  name        = "Clixx app mysql"
  description = "MySql Security Group For CliXX App"
  vpc_id      = aws_vpc.clixx-app-vpc.id
  tags = {
    Name = "Clixx app mysql"
  }
}

## Load Balancer Rules

resource "aws_security_group_rule" "loadbalancer_ingress_80" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.clixx-app-loadbalancer.id
}

resource "aws_security_group_rule" "loadbalancer_ingress_443" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.clixx-app-loadbalancer.id
}

resource "aws_security_group_rule" "loadbalancer_egress_80" {
  type                     = "egress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.clixx-app-loadbalancer.id
  source_security_group_id = aws_security_group.clixx-app-server.id
}

resource "aws_security_group_rule" "loadbalancer_egress_443" {
  type                     = "egress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.clixx-app-loadbalancer.id
  source_security_group_id = aws_security_group.clixx-app-server.id
}

resource "aws_security_group_rule" "loadbalancer_egress_2049" {
  type                     = "egress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  security_group_id        = aws_security_group.clixx-app-loadbalancer.id
  source_security_group_id = aws_security_group.clixx-app-server.id
}

## App Server Rules

resource "aws_security_group_rule" "app_server_ingress_22" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.clixx-app-server.id
  source_security_group_id = aws_security_group.clixx-bastion-server.id
}

resource "aws_security_group_rule" "app_server_ingress_443" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.clixx-app-server.id
  source_security_group_id = aws_security_group.clixx-app-loadbalancer.id
}

resource "aws_security_group_rule" "app_server_ingress_2049" {
  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  security_group_id        = aws_security_group.clixx-app-server.id
  source_security_group_id = aws_security_group.clixx-app-loadbalancer.id
}

resource "aws_security_group_rule" "app_server_ingress_80" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.clixx-app-server.id
  source_security_group_id = aws_security_group.clixx-app-loadbalancer.id
}

resource "aws_security_group_rule" "app_server_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.clixx-app-server.id
}

## Bastion Server Rules

resource "aws_security_group_rule" "bastion_server_ingress_22" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.clixx-bastion-server.id
}

resource "aws_security_group_rule" "bastion_server_egress_22" {
  type                     = "egress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.clixx-bastion-server.id
  source_security_group_id = aws_security_group.clixx-app-server.id
}

resource "aws_security_group_rule" "bastion_server_egress_443" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.clixx-bastion-server.id
}

resource "aws_security_group_rule" "bastion_server_egress_80" {
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.clixx-bastion-server.id
}

resource "aws_security_group_rule" "bastion_server_egress_mysql" {
  type                     = "egress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.clixx-bastion-server.id
  source_security_group_id = aws_security_group.clixx-app-mysql.id
}

## MySQL Security Group Rules

resource "aws_security_group_rule" "mysql_ingress_app_server" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.clixx-app-mysql.id
  source_security_group_id = aws_security_group.clixx-app-server.id
}

resource "aws_security_group_rule" "mysql_ingress_bastion" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.clixx-app-mysql.id
  source_security_group_id = aws_security_group.clixx-bastion-server.id
}

