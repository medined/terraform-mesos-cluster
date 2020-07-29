variable "instance_type" {
  type = string
  default = "t3.micro"
}
variable "image_id" {
  type = string
  default = "ami-09d95fab7fff3776c"
}
variable "key_pair_name" {
  type = string
  default = "ecs-key-pair-us-east-1"
}
variable "cluster_id" {
  type = string
  default = "cluster-default-id"
}
variable "subnet_id" {
  type = string
  default = "subnet-d76fb78a"
}
variable "instance_profile_name" {
  type = string
  default = "ecsInstanceRole"
}
variable "security_groups" {
  type = list(string)
  default = ["sg-69e3fc1c"]
}
variable "environment" {
  type = string
  default = "development"
}
variable "enabled" {
  type = bool
  default = true
}
variable "region" { type = string }