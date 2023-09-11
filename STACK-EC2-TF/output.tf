###OUTPUT SUBNET CIDRS
# data "aws_subnet_ids" "stack_sub_id_list" {
#  vpc_id = var.vpc_id
# }

# data "aws_subnet" "stack_subnets" {
#  for_each = data.aws_subnet_ids.stack_sub_id_list.ids
#  id       = each.value
# }


#data "aws_availability_zones" "az" {
#}

# output "subnet_id" {
# # #  #value = [for s in data.aws_subnet.stack_subnets : s.cidr_block]
#   #  value = [for s in data.aws_subnet.stack_subnets : s.id]
#   # value = [for s in data.aws_subnet.stack_subnets : element(split("-", s.availability_zone), 2)]
#  }

#data "aws_subnets" "subnets" {
# filter {
#  name   = "vpc-id"
# values = [var.vpc_id]
#}
#}

#data "aws_subnet" "subnet" {
# for_each = toset(data.aws_subnets.subnets.ids)
# id       = each.value
#}

#output "subnet" {
# value = [for subnet in data.aws_subnet.subnet : subnet.id]
#}
