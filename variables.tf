variable "default_region" {
  default = "us-east-2"
}
variable "default_az" {
  default = "a"
}
variable "key_pair_name" {
  default = "ecs-key-pair"
}

variable "zookeeper_image_id" {
  type    = map
  default = {
    "us-east-1" = "ami-039a49e70ea773ffc"
    "us-east-2" = "ami-04781752c9b20ea41"
  }
}
variable "mesos_image_id" {
  type    = map
  default = {
    "us-east-1" = "ami-039a49e70ea773ffc"
    "us-east-2" = "ami-04781752c9b20ea41"
  }
}
variable "zookeeper_instance_type" {
  default = "t3.micro"
}
variable "mesos_instance_type" {
  default = "t3.micro"
}
variable "environment" {
  default = "development"
}

variable "splunk_image_id" {
  type    = map
  default = {
    "us-east-1" = "ami-039a49e70ea773ffc"
    "us-east-2" = "ami-04781752c9b20ea41"
  }
}
variable "splunk_instance_type" {
  default = "t3.small"
}
variable "enable_splunk" {
  type = bool
  default = true
}

variable "fluentd_image_id" {
  type    = map
  default = {
    "us-east-1" = "ami-09d95fab7fff3776c"
    "us-east-2" = "ami-0e067567dbf210b67"
  }
}
variable "fluentd_instance_type" {
  default = "t3.micro"
}
variable "enable_fluentd" {
  type = bool
  default = true
}

variable "availability_zones" {
  type    = map
  default = {
    "us-east-1" = ["us-east-1a", "us-east-1b", "us-east-1c"]
    "us-east-2" = ["us-east-2a", "us-east-2b", "us-east-2c"]
  }
}

