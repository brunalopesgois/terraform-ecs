resource "aws_vpc" "ecs_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    name = "ecs_vpc"
  }
}

resource "aws_subnet" "ecs_subnet_az1" {
  vpc_id                  = aws_vpc.ecs_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.ecs_vpc.cidr_block, 8, 1)
  map_public_ip_on_launch = true
  availability_zone       = "${data.aws_region.current.name}a"
}

resource "aws_subnet" "ecs_subnet_az2" {
  vpc_id                  = aws_vpc.ecs_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.ecs_vpc.cidr_block, 8, 2)
  map_public_ip_on_launch = true
  availability_zone       = "${data.aws_region.current.name}b"
}

resource "aws_internet_gateway" "ecs_igw" {
  vpc_id = aws_vpc.ecs_vpc.id
  tags = {
    Name = "ecs_igw"
  }
}

resource "aws_route_table" "ecs_rtb" {
  vpc_id = aws_vpc.ecs_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ecs_igw.id
  }
}

resource "aws_route_table_association" "ecs_subnet_az1_rtb" {
  subnet_id      = aws_subnet.ecs_subnet_az1.id
  route_table_id = aws_route_table.ecs_rtb.id
}

resource "aws_route_table_association" "ecs_subnet_az2_rtb" {
  subnet_id      = aws_subnet.ecs_subnet_az2.id
  route_table_id = aws_route_table.ecs_rtb.id
}

resource "aws_security_group" "ecs_sg" {
  name   = "ecs-sg"
  vpc_id = aws_vpc.ecs_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    self        = "false"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
