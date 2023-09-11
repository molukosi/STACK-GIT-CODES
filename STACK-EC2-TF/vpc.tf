resource "aws_vpc" "clixx-app-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "clixx-app-vpc"
  }
}

resource "aws_internet_gateway" "clixx_app_igw" {
  vpc_id = aws_vpc.clixx-app-vpc.id

  tags = {
    Name = "clixx_app_igw"
  }
}

resource "aws_subnet" "clixx-pub1" {
  vpc_id                  = aws_vpc.clixx-app-vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public_Subnet_EC2_Bastion1"
  }
}

resource "aws_subnet" "clixx-pub2" {
  vpc_id                  = aws_vpc.clixx-app-vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public_Subnet2_EC2_Bastion2"
  }
}

resource "aws_route_table_association" "clixx-pub1-association" {
  subnet_id      = aws_subnet.clixx-pub1.id
  route_table_id = aws_route_table.clixx-app-rtpub.id
}

resource "aws_route_table_association" "clixx-pub2-association" {
  subnet_id      = aws_subnet.clixx-pub2.id
  route_table_id = aws_route_table.clixx-app-rtpub.id
}


resource "aws_eip" "clixx-app-eip" {
  domain = "vpc"

  tags = {
    Name = "Clixx App NAT EIP"
  }
}


resource "aws_nat_gateway" "clixx-app-nat" {
  allocation_id = aws_eip.clixx-app-eip.id
  subnet_id     = aws_subnet.clixx-pub1.id

  tags = {
    Name = "Clixx App NAT Gateway"
  }
}

resource "aws_route_table" "clixx-app-rtpub" {
  vpc_id = aws_vpc.clixx-app-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.clixx_app_igw.id
  }

  tags = {
    Name = "clixx-app-rtpub"
  }
}

resource "aws_route_table" "clixx-app-rtpriv" {
  vpc_id = aws_vpc.clixx-app-vpc.id

  tags = {
    Name = "Private Route Table"
  }
}

resource "aws_route" "nat_gateway_route" {
  route_table_id         = aws_route_table.clixx-app-rtpriv.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.clixx-app-nat.id
}


resource "aws_subnet" "clixx-priv1-appserv1" {
  vpc_id                  = aws_vpc.clixx-app-vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "Private_Subnet_Application_Server1"
  }
}

resource "aws_route_table_association" "privsub1" {
  subnet_id      = aws_subnet.clixx-priv1-appserv1.id
  route_table_id = aws_route_table.clixx-app-rtpriv.id
}

resource "aws_subnet" "clixx-priv2-appserv2" {
  vpc_id                  = aws_vpc.clixx-app-vpc.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false

  tags = {
    Name = "Private_Subnet_Application_Server2"
  }
}

resource "aws_route_table_association" "privsub2" {
  subnet_id      = aws_subnet.clixx-priv2-appserv2.id
  route_table_id = aws_route_table.clixx-app-rtpriv.id
}

resource "aws_subnet" "clixx-priv3-appServ1" {
  vpc_id                  = aws_vpc.clixx-app-vpc.id
  cidr_block              = "10.0.24.0/22"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "Private_Subnet_Application_DB1"
  }
}

resource "aws_route_table_association" "privsub3" {
  subnet_id      = aws_subnet.clixx-priv3-appServ1.id
  route_table_id = aws_route_table.clixx-app-rtpriv.id
}

resource "aws_subnet" "clixx-priv4-appServ2" {
  vpc_id                  = aws_vpc.clixx-app-vpc.id
  cidr_block              = "10.0.28.0/22"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false

  tags = {
    Name = "Private_Subnet_Application_DB2"
  }
}

resource "aws_route_table_association" "privsub4" {
  subnet_id      = aws_subnet.clixx-priv4-appServ2.id
  route_table_id = aws_route_table.clixx-app-rtpriv.id
}

resource "aws_subnet" "clixx-priv5-javaDB1" {
  vpc_id                  = aws_vpc.clixx-app-vpc.id
  cidr_block              = "10.0.5.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "Private_Subnet_Java_App_DB1"
  }
}

resource "aws_route_table_association" "privsub5" {
  subnet_id      = aws_subnet.clixx-priv5-javaDB1.id
  route_table_id = aws_route_table.clixx-app-rtpriv.id
}


resource "aws_subnet" "clixx-priv6-javaDB2" {
  vpc_id                  = aws_vpc.clixx-app-vpc.id
  cidr_block              = "10.0.6.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false

  tags = {
    Name = "Private_Subnet_Java_App_DB2"
  }
}

resource "aws_route_table_association" "privsub6" {
  subnet_id      = aws_subnet.clixx-priv6-javaDB2.id
  route_table_id = aws_route_table.clixx-app-rtpriv.id
}

resource "aws_subnet" "clixx-priv7-javaserv1" {
  vpc_id                  = aws_vpc.clixx-app-vpc.id
  cidr_block              = "10.0.7.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "Private_Subnet_Java_App_Server1"
  }
}

resource "aws_route_table_association" "privsub7" {
  subnet_id      = aws_subnet.clixx-priv7-javaserv1.id
  route_table_id = aws_route_table.clixx-app-rtpriv.id
}

resource "aws_subnet" "clixx-priv8-javaserv2" {
  vpc_id                  = aws_vpc.clixx-app-vpc.id
  cidr_block              = "10.0.8.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false

  tags = {
    Name = "Private_Subnet_Java_App_Server2"
  }
}

resource "aws_route_table_association" "privsub8" {
  subnet_id      = aws_subnet.clixx-priv8-javaserv2.id
  route_table_id = aws_route_table.clixx-app-rtpriv.id
}

resource "aws_subnet" "clixx-priv9-oracleDB1" {
  vpc_id                  = aws_vpc.clixx-app-vpc.id
  cidr_block              = "10.0.12.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "Private_Subnet_OracleDB"
  }
}

resource "aws_route_table_association" "privsub9" {
  subnet_id      = aws_subnet.clixx-priv9-oracleDB1.id
  route_table_id = aws_route_table.clixx-app-rtpriv.id
}

resource "aws_subnet" "clixx-priv10-oracleDB2" {
  vpc_id                  = aws_vpc.clixx-app-vpc.id
  cidr_block              = "10.0.16.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false

  tags = {
    Name = "Private_Subnet_OracleDB-Clone"
  }
}

resource "aws_route_table_association" "privsub10" {
  subnet_id      = aws_subnet.clixx-priv10-oracleDB2.id
  route_table_id = aws_route_table.clixx-app-rtpriv.id
}

resource "aws_db_subnet_group" "clixx_db_subnet_group" {
  name       = "clixx-database-subnet-group"
  subnet_ids = [aws_subnet.clixx-priv1-appserv1.id, aws_subnet.clixx-priv2-appserv2.id]

  tags = {
    Name = "My database subnet group"
  }
}
