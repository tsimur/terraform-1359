 variable "region" {
   type = string
   default = "us-west-2"
 }
variable "private_subnates_names" {
  type = list
  default = ["private_subnet_north", "private_subnet_south"]  
}

variable "public_subnates_names" {
  type = list
  default = ["public_subnet_north", "public_subnet_south"]  
}

variable "private_subnates_ips" {
  type = list
  default = ["10.0.1.0/24", "10.0.2.0/24"]  
}

variable "public_subnates_ips" {
  type = list
  default = ["10.0.3.0/24", "10.0.4.0/24"]  
}

variable "ec2_names" {
  type = list
  default = ["website_north", "website_south"]  
}

 variable "ami_owner" {
   type = list
   default = ["099720109477"]
 }

 variable "os_image" {
   type = list
   default = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20220420"]
 }