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

variable "av_zone_ids" {
  type = list
  default = ["use1-az3", "use1-az4"]  
}

variable "ec2_names" {
  type = list
  default = ["website_north", "website_south"]  
}