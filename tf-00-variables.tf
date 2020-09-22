variable "enable_fluentd" {
  type    = bool
  default = true
}
variable "enable_splunk" {
  type    = bool
  default = true
}
variable "fluentd_image_id" {
  default = "ami-09d95fab7fff3776c"
}
variable "fluentd_instance_type" {
  default = "t3.micro"
}
variable "environment" {
  default = "development"
}
variable "key_pair_name" {
  default = "kodiak-davidm"
}
variable "mesos_image_id" {
  default = "ami-039a49e70ea773ffc"
}
variable "mesos_instance_type" {
  default = "t3.micro"
}
variable "aws_profile_name" {
  default = "bluejay"
}
variable "region" {
  default = "us-east-1"
}
variable "splunk_image_id" {
  default = "ami-039a49e70ea773ffc"
}
variable "splunk_instance_type" {
  default = "t3.small"
}
variable "zookeeper_image_id" {
  default = "ami-039a49e70ea773ffc"
}
variable "zookeeper_instance_type" {
  default = "t3.micro"
}
