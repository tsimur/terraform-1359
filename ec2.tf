resource "aws_instance" "website" {
  ami                     = "ami-0dc5e9ff792ec08e3"
  instance_type           = "t2.micro"
  key_name                = aws_key_pair.deployer.key_name
  vpc_security_group_ids  = [aws_security_group.allow_tls.id]
  subnet_id               = aws_subnet.private_subnets[count.index].id
  iam_instance_profile    = "AmazonSSMRoleForInstancesQuickSetup"
  count                   = 2

  user_data = file("sc.sh")

  tags = {
    Name = var.ec2_names[count.index]
  }
}