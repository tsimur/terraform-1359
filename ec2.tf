resource "aws_instance" "website" {
  ami                     = data.aws_ami.ubuntu.id
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

data "aws_ami" "ubuntu" {
  owners = var.ami_owner

  filter {
    name   = "name"
    values = var.os_image
  }
}