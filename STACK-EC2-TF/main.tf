locals {
  #  Server_Prefix = "CliXX-"
  Server_Prefix = ""
}

data "aws_secretsmanager_secret_version" "stack_clixx_secrets" {
  secret_id = "stack_clixx_secrets"
}

locals {
  db_creds =jsondecode(
    data.aws_secretsmanager_secret_version.stack_clixx_secrets.secret_string
  )
}

resource "aws_key_pair" "Stack_KP" {
  key_name   = "stackkp"
  public_key = file(var.PATH_TO_PUBLIC_KEY)
}

resource "aws_instance" "Server" {
  ami                    = var.ami
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.clixx-bastion-server.id]
  user_data              = data.template_file.bootstrap.rendered
  key_name               = aws_key_pair.Stack_KP.key_name
  subnet_id              = aws_subnet.clixx-pub1.id

  tags = {
    Name        = "stack-clixx-app"
    Environment = var.environment
  }
}

resource "aws_launch_template" "launch-template" {
  name_prefix   = "clixx-app-launch-template"
  image_id      = var.ami
  instance_type = var.instance_type
  key_name      = aws_key_pair.Stack_KP.key_name
  user_data     = base64encode(data.template_file.bootstrap.rendered)

  network_interfaces {
    associate_public_ip_address = true
    delete_on_termination       = true
    security_groups             = [aws_security_group.clixx-app-server.id]
  }

  block_device_mappings {
    device_name = "/dev/sdb"
    ebs {
      volume_size           = 20
      volume_type           = "gp2"
      delete_on_termination = true
    }
  }

  block_device_mappings {
    device_name = "/dev/sdc"
    ebs {
      volume_size           = 20
      volume_type           = "gp2"
      delete_on_termination = true
    }
  }

  block_device_mappings {
    device_name = "/dev/sdd"
    ebs {
      volume_size           = 20
      volume_type           = "gp2"
      delete_on_termination = true
    }
  }

  block_device_mappings {
    device_name = "/dev/sde"
    ebs {
      volume_size           = 20
      volume_type           = "gp2"
      delete_on_termination = true
    }
  }

}


resource "aws_lb_target_group" "clixx-app-target-group" {
  name     = "clixx-app-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.clixx-app-vpc.id

  health_check {
    enabled             = true
    interval            = 30
    path                = "/"
    port                = 80
    timeout             = 10
    healthy_threshold   = 5
    unhealthy_threshold = 4
    matcher             = "200-299"
  }
}

resource "aws_lb_target_group_attachment" "register-ec2-target" {
  target_group_arn = aws_lb_target_group.clixx-app-target-group.arn
  target_id        = aws_instance.Server.id
  port             = 80
}


resource "aws_lb" "clixx-app-load-balancer" {
  name               = "clixx-app-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.clixx-app-loadbalancer.id]
  subnets            = [aws_subnet.clixx-pub1.id, aws_subnet.clixx-pub2.id]

  enable_deletion_protection = false

  enable_cross_zone_load_balancing = true
}

resource "aws_lb_listener" "clixx-app-listener" {
  load_balancer_arn = aws_lb.clixx-app-load-balancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.clixx-app-target-group.arn
  }
}

resource "aws_efs_file_system" "stack-clixx-EFS" {
  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }

  tags = {
    Name = "stack-clixx-EFS"
  }
}

resource "aws_efs_mount_target" "stack-clixx-EFS-Mount" {
  file_system_id  = aws_efs_file_system.stack-clixx-EFS.id
  subnet_id       = aws_subnet.clixx-pub1.id
  security_groups = [aws_security_group.clixx-app-server.id]
}

resource "aws_autoscaling_group" "auto-scaling" {
  name                = "clixx-app-auto-scaling"
  desired_capacity    = 1
  max_size            = 3
  min_size            = 1
  vpc_zone_identifier = [aws_subnet.clixx-pub1.id, aws_subnet.clixx-pub2.id]
  count               = var.number_of_asgs

  launch_template {
    id      = aws_launch_template.launch-template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "stack-clixx-app-ASG-${count.index + 1}"
    propagate_at_launch = true
  }

  target_group_arns = [aws_lb_target_group.clixx-app-target-group.arn]

  tag {
    key                 = "environment"
    value               = "Dev"
    propagate_at_launch = true
  }
}

