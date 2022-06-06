resource "aws_eip" "nat" {
    tags = {
    Name = "nat_ip"
  }
}