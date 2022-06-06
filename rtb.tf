resource "aws_route_table" "rtb_private_subnets" {
  vpc_id = aws_vpc.web_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.gw-nat.id
  }

  tags = {
    Name = "rtb_private"
  }
}

resource "aws_route_table" "rtb_public_subnets" {
  vpc_id = aws_vpc.web_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw-internet.id
  }

  tags = {
    Name = "rtb_public"
  }
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private_subnets[count.index].id
  count          = 2
  route_table_id = aws_route_table.rtb_private_subnets.id
}


resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public_subnets[count.index].id
  count          = 2
  route_table_id = aws_route_table.rtb_public_subnets.id
}