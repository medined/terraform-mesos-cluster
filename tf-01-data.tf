data "aws_vpc" "default_vpc" {
  tags = { "Default" = "true" }
}

data "aws_subnet" "subnet_us_east_1d" {
  filter {
    name   = "vpc-id"
    values = ["${data.aws_vpc.default_vpc.id}"]
  }
  filter {
    name   = "availability-zone"
    values = ["us-east-1a"]
  }
}

data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

data "aws_availability_zones" "available" {
    state = "available"
}
