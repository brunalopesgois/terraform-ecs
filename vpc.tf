resource "aws_vpc" "unionaudio-backend-vpc" {
  cidr_block = "172.16.0.0/16"
}

# Fetch AZs in the current region
data "aws_availability_zones" "available" {
}

# Create var.az_count private subnets, each in a different AZ
resource "aws_subnet" "unionaudio-backend-private" {
  count             = var.az_count
  cidr_block        = cidrsubnet(aws_vpc.unionaudio-backend-vpc.cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  vpc_id            = aws_vpc.unionaudio-backend-vpc.id
}

# Create var.az_count public subnets, each in a different AZ
resource "aws_subnet" "unionaudio-backend-public" {
  count                   = var.az_count
  cidr_block              = cidrsubnet(aws_vpc.unionaudio-backend-vpc.cidr_block, 8, var.az_count + count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  vpc_id                  = aws_vpc.unionaudio-backend-vpc.id
  map_public_ip_on_launch = true
}

# Internet Gateway for the public subnet
resource "aws_internet_gateway" "unionaudio-backend-igw" {
  vpc_id = aws_vpc.unionaudio-backend-vpc.id
}

# Route the public subnet traffic through the IGW
resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.unionaudio-backend-vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.unionaudio-backend-igw.id
}

# Create a NAT gateway with an Elastic IP for each private subnet to get internet connectivity-
resource "aws_eip" "unionaudio-backend-eip" {
  count      = var.az_count
  vpc        = true
  depends_on = [aws_internet_gateway.unionaudio-backend-igw]
}

resource "aws_nat_gateway" "unionaudio-backend-natgw" {
  count         = var.az_count
  subnet_id     = element(aws_subnet.unionaudio-backend-public.*.id, count.index)
  allocation_id = element(aws_eip.unionaudio-backend-eip.*.id, count.index)
}

# Create a new route table for the private subnets, make it route non-local traffic through the NAT gateway to the internet
resource "aws_route_table" "unionaudio-backend-private-rtb" {
  count  = var.az_count
  vpc_id = aws_vpc.unionaudio-backend-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.unionaudio-backend-natgw.*.id, count.index)
  }
}

# Explicitly associate the newly created route tables to the private subnets (so they don't default to the main route table)
resource "aws_route_table_association" "unionaudio-backend-private-rtb-assoc" {
  count          = var.az_count
  subnet_id      = element(aws_subnet.unionaudio-backend-private.*.id, count.index)
  route_table_id = element(aws_route_table.unionaudio-backend-private-rtb.*.id, count.index)
}
