# ------------------------------------------------------------------------------------
# Zookeeper instance (standalone for now)
# ------------------------------------------------------------------------------------

module "zookeeper" {
  source = "./modules/zookeeper"

  instance_type         = var.zookeeper_instance_type
  image_id              = var.zookeeper_image_id
  key_pair_name         = var.key_pair_name
  cluster_id            = random_id.cluster_id.b64_std
  subnet_id             = data.aws_subnet.subnet_us_east_1d.id
  instance_profile_name = aws_iam_instance_profile.mesos_ec2_instance_profile.name
  security_groups       = [aws_security_group.mesos_security_group.id]
  environment           = terraform.workspace
}

# ------------------------------------------------------------------------------------
# Splunk instance (standalone for now)
# ------------------------------------------------------------------------------------
module "splunk" {
  source = "./modules/splunk"

  enabled               = var.enable_splunk
  instance_type         = var.splunk_instance_type
  image_id              = var.splunk_image_id
  key_pair_name         = var.key_pair_name
  cluster_id            = random_id.cluster_id.b64_std
  subnet_id             = data.aws_subnet.subnet_us_east_1d.id
  instance_profile_name = aws_iam_instance_profile.mesos_ec2_instance_profile.name
  security_groups       = [aws_security_group.mesos_security_group.id]
  environment           = terraform.workspace
}

# ------------------------------------------------------------------------------------
# Fluentd instance (standalone for now)
# ------------------------------------------------------------------------------------
//module "fluentd" {
//    source = "./modules/fluentd"
//
//    enabled = var.enable_fluentd
//    instance_type = var.fluentd_instance_type
//    image_id = var.fluentd_image_id
//    key_pair_name = var.key_pair_name
//    cluster_id = random_id.cluster_id.b64_std
//    subnet_id = data.aws_subnet.subnet_us_east_1d.id
//    instance_profile_name = aws_iam_instance_profile.mesos_ec2_instance_profile.name
//    security_groups = [aws_security_group.mesos_security_group.id]
//    environment = terraform.workspace
//}

# ------------------------------------------------------------------------------------
# Mesos Master(s)
# ------------------------------------------------------------------------------------


module "mesos-master" {
  source = "./modules/mesos"

  mesos_type            = "Master"
  mesos_image_id        = var.mesos_image_id
  key_pair_name         = var.key_pair_name
  instance_profile_name = aws_iam_instance_profile.mesos_ec2_instance_profile.name
  security_groups       = [aws_security_group.mesos_security_group.id]
  instance_type         = var.mesos_instance_type
  cluster_id            = random_id.cluster_id.b64_std
  asg_min_size          = 0
  asg_max_size          = 1
  asg_desired_capacity  = 1
  environment           = terraform.workspace
}

# ------------------------------------------------------------------------------------
# Mesos Agent(s)
# ------------------------------------------------------------------------------------

module "mesos-agent" {
  source = "./modules/mesos"

  mesos_type            = "Agent"
  mesos_image_id        = var.mesos_image_id
  key_pair_name         = var.key_pair_name
  instance_profile_name = aws_iam_instance_profile.mesos_ec2_instance_profile.name
  security_groups       = [aws_security_group.mesos_security_group.id]
  instance_type         = var.mesos_instance_type
  cluster_id            = random_id.cluster_id.b64_std
  asg_min_size          = 0
  asg_max_size          = 4
  asg_desired_capacity  = 1
  environment           = terraform.workspace
}

# ------------------------------------------------------------------------------------
# Mesos Marathon Framework(s)
# ------------------------------------------------------------------------------------

module "mesos-marathon" {
  source = "./modules/mesos"
  mesos_type            = "Marathon"
  mesos_image_id        = var.mesos_image_id
  key_pair_name         = var.key_pair_name
  instance_profile_name = aws_iam_instance_profile.mesos_ec2_instance_profile.name
  security_groups       = [aws_security_group.mesos_security_group.id]
  instance_type         = var.mesos_instance_type
  cluster_id            = random_id.cluster_id.b64_std
  asg_min_size          = 0
  asg_max_size          = 2
  asg_desired_capacity  = 1
  environment           = terraform.workspace
}