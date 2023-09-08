locals {
  #  Server_Prefix = "CliXX-"
  Server_Prefix = ""
}

resource "aws_key_pair" "Stack_KP" {
  key_name   = "stackkp"
  public_key = file(var.PATH_TO_PUBLIC_KEY)
}

resource "aws_instance" "Server" {
  ami                    = var.ami
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.stack-sg.id]
  user_data              = var.bootstrap_file
  key_name               = aws_key_pair.Stack_KP.key_name
  subnet_id              = var.subnet_ids[0]

  root_block_device {
    volume_type = var.EC2_DETAILS["volume_type"]
    volume_size = var.EC2_DETAILS["volume_size"]
    delete_on_termination = var.EC2_DETAILS["delete_on_termination"]
    encrypted = var.EC2_DETAILS["encrypted"]
  }

  tags = merge(var.required_tags, {"Name"="stack-server-0"})
}

output "rendered_script" {
  value = var.bootstrap_file
}


  #tags = {
   # Name = "EC2_MODULE"
  #}
  


