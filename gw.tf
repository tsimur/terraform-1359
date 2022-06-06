resource "aws_internet_gateway" "gw-internet" {
  vpc_id = aws_vpc.web_vpc.id

  tags = {
    Name = "gw-internet"
  }
}


resource "aws_nat_gateway" "gw-nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnets[1].id

  tags = {
    Name = "gw-nat"
  }
}