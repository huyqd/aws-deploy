resource "aws_security_group" "aws-deploy" {
  name   = local.project_name
  vpc_id = aws_vpc.app_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "service-sg" {
  name   = "service-sg"
  vpc_id = aws_vpc.app_vpc.id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    # Only allowing traffic in from the load balancer security group
    security_groups = [aws_security_group.aws-deploy.id]
  }

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    # Only allowing traffic in from the load balancer security group
    security_groups = [aws_security_group.aws-deploy.id]
  }


  egress {
    from_port   = 0             # Allowing any incoming port
    to_port     = 0             # Allowing any outgoing port
    protocol    = "-1"          # Allowing any outgoing protocol
    cidr_blocks = ["0.0.0.0/0"] # Allowing traffic out to all IP addresses
  }
}

#resource "aws_eip" "public" {
#  vpc      = true
#  instance = aws_instance.aws-deploy.id
#}

resource "aws_vpc" "app_vpc" {
  cidr_block = "10.1.0.0/16"

  tags = {
    Name = "app-vpc"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.app_vpc.id

  tags = {
    Name = "gw"
  }
}

resource "aws_subnet" "public-subnet-1" {
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = "10.1.1.0/24"
  availability_zone       = "eu-central-1a"

  tags = {
    Name = "public-subnet-1"
  }
}

resource "aws_subnet" "public-subnet-2" {
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = "10.1.2.0/24"
  availability_zone = "eu-central-1b"

  tags = {
    Name = "public-subnet-2"
  }
}

#resource "aws_subnet" "private-subnet-1" {
#  vpc_id            = aws_vpc.app_vpc.id
#  cidr_block        = "10.1.3.0/24"
#  availability_zone = "eu-central-1a"
#
#  tags = {
#    Name = "private-subnet-1"
#  }
#}
#
#resource "aws_subnet" "private-subnet-2" {
#  vpc_id            = aws_vpc.app_vpc.id
#  cidr_block        = "10.1.4.0/24"
#  availability_zone = "eu-central-1b"
#
#  tags = {
#    Name = "private-subnet-2"
#  }
#}

resource "aws_route_table" "route_table_public" {
  vpc_id = aws_vpc.app_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "app-routetable-public"
  }
}

resource "aws_route_table_association" "public-subnet-1" {
  subnet_id      = aws_subnet.public-subnet-1.id
  route_table_id = aws_route_table.route_table_public.id
}

resource "aws_route_table_association" "public-subnet-2" {
  subnet_id      = aws_subnet.public-subnet-2.id
  route_table_id = aws_route_table.route_table_public.id
}

