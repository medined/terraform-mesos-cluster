terraform {
  backend "s3" {
    bucket = "terraform-remote-state-mesos"
    key    = "cluster/mesos/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "terraform-state-locking"
  }
}

provider "aws" {
  profile = "default"
  region  = var.default_region
}

data "aws_vpc" "default_vpc" {
  tags = { "Default" = "true" }
}

data "aws_subnet" "region_subnet" {
  filter {
    name   = "vpc-id"
    values = ["${data.aws_vpc.default_vpc.id}"] # insert value here
  }
  filter {
    name = "availability-zone"
    values = ["${var.default_region}${var.default_az}"]
  }
}

data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

# Unique id to reference all other resouces under this template (useful for tags)
resource "random_id" "cluster_id" {
  byte_length = 8
}

# ------------------------------------------------------------------------------------
# Mesos security group shared across all components for ease
# ------------------------------------------------------------------------------------
resource "aws_security_group" "mesos_security_group" {
  name        = "mesos_security_group_${terraform.workspace}"
  description = "Mesos shared security group"
  vpc_id      = data.aws_vpc.default_vpc.id

  tags = {
    Name = "mesos-shared-security-group_${terraform.workspace}"
  }
}

resource "aws_security_group_rule" "all_egress" {
  type              = "egress"
  from_port         = -1
  to_port           = -1
  protocol          = -1
  security_group_id = aws_security_group.mesos_security_group.id
  cidr_blocks       = ["0.0.0.0/0"]
}
resource "aws_security_group_rule" "mesos_security_group_self_to" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = -1
  security_group_id        = aws_security_group.mesos_security_group.id
  source_security_group_id = aws_security_group.mesos_security_group.id
}
resource "aws_security_group_rule" "home_router_cidr" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  security_group_id = aws_security_group.mesos_security_group.id
  cidr_blocks       = ["${chomp(data.http.myip.body)}/32"]
}

# ------------------------------------------------------------------------------------
# Instance profile used across all Mesos components
# ------------------------------------------------------------------------------------

resource "aws_iam_role" "mesos_ec2_role" {
  name = "mesos_ec2_role_${terraform.workspace}"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": [
                    "ec2.amazonaws.com"
                ]
            },
            "Action": [
                "sts:AssumeRole"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "s3_full_attachment" {
  role       = aws_iam_role.mesos_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
resource "aws_iam_role_policy_attachment" "ec2_full_attachment" {
  role       = aws_iam_role.mesos_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}
resource "aws_iam_role_policy_attachment" "ecr_full_attachment" {
  role       = aws_iam_role.mesos_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

resource "aws_iam_instance_profile" "mesos_ec2_instance_profile" {
  name = "mesos_ec2_instance_profile_${terraform.workspace}"
  role = aws_iam_role.mesos_ec2_role.name
}


# ------------------------------------------------------------------------------------
# Zookeeper instance (standalone for now)
# ------------------------------------------------------------------------------------

module "zookeeper" {
    source = "./modules/zookeeper"

    instance_type = var.zookeeper_instance_type
    image_id = var.zookeeper_image_id[var.default_region]
    key_pair_name = "${var.key_pair_name}-${var.default_region}"
    cluster_id = random_id.cluster_id.hex
    subnet_id = data.aws_subnet.region_subnet.id
    instance_profile_name = aws_iam_instance_profile.mesos_ec2_instance_profile.name
    security_groups = [aws_security_group.mesos_security_group.name]
    environment = terraform.workspace
    azs = var.availability_zones[var.default_region]
    region = var.default_region
}

# ------------------------------------------------------------------------------------
# Splunk instance (standalone for now)
# ------------------------------------------------------------------------------------
//module "splunk" {
//    source = "./modules/splunk"
//
//    enabled = var.enable_splunk
//    instance_type = var.splunk_instance_type
//    image_id = var.splunk_image_id[var.default_region]
//    key_pair_name = "${var.key_pair_name}-${var.default_region}"
//    cluster_id = random_id.cluster_id.hex
//    subnet_id = data.aws_subnet.region_subnet.id
//    instance_profile_name = aws_iam_instance_profile.mesos_ec2_instance_profile.name
//    security_groups = [aws_security_group.mesos_security_group.id]
//    environment = terraform.workspace
//    region = var.default_region
//}

# ------------------------------------------------------------------------------------
# Fluentd instance (standalone for now)
# ------------------------------------------------------------------------------------
//module "fluentd" {
//    source = "./modules/fluentd"
//
//    enabled = var.enable_fluentd
//    instance_type = var.fluentd_instance_type
//    image_id = var.fluentd_image_id[var.default_region]
//    key_pair_name = "${var.key_pair_name}-${var.default_region}"
//    cluster_id = random_id.cluster_id.hex
//    subnet_id = data.aws_subnet.region_subnet.id
//    instance_profile_name = aws_iam_instance_profile.mesos_ec2_instance_profile.name
//    security_groups = [aws_security_group.mesos_security_group.id]
//    environment = terraform.workspace
//    region = var.default_region
//}

# ------------------------------------------------------------------------------------
# Mesos Master(s)
# ------------------------------------------------------------------------------------

module "mesos-master" {
    source = "./modules/mesos"

    mesos_type = "Master"
    mesos_image_id = var.mesos_image_id[var.default_region]
    key_pair_name = "${var.key_pair_name}-${var.default_region}"
    instance_profile_name = aws_iam_instance_profile.mesos_ec2_instance_profile.name
    security_groups = [aws_security_group.mesos_security_group.id]
    instance_type = var.mesos_instance_type
    cluster_id = random_id.cluster_id.hex
    asg_min_size = 0
    asg_max_size = 1
    asg_desired_capacity = 1
    environment = terraform.workspace
    azs = var.availability_zones[var.default_region]
    region = var.default_region
}

# ------------------------------------------------------------------------------------
# Mesos Agent(s)
# ------------------------------------------------------------------------------------

//module "mesos-agent" {
//    source = "./modules/mesos"
//
//    mesos_type = "Agent"
//    mesos_image_id = var.mesos_image_id[var.default_region]
//    key_pair_name = "${var.key_pair_name}-${var.default_region}"
//    instance_profile_name = aws_iam_instance_profile.mesos_ec2_instance_profile.name
//    security_groups = [aws_security_group.mesos_security_group.id]
//    instance_type = var.mesos_instance_type
//    cluster_id = random_id.cluster_id.hex
//    asg_min_size = 0
//    asg_max_size = 4
//    asg_desired_capacity = 1
//    environment = terraform.workspace
//}

# ------------------------------------------------------------------------------------
# Mesos Marathon Framework(s)
# ------------------------------------------------------------------------------------

module "mesos-marathon" {
    source = "./modules/mesos"

    mesos_type = "Marathon"
    mesos_image_id = var.mesos_image_id[var.default_region]
    key_pair_name = "${var.key_pair_name}-${var.default_region}"
    instance_profile_name = aws_iam_instance_profile.mesos_ec2_instance_profile.name
    security_groups = [aws_security_group.mesos_security_group.id]
    instance_type = var.mesos_instance_type
    cluster_id = random_id.cluster_id.hex
    asg_min_size = 0
    asg_max_size = 2
    asg_desired_capacity = 1
    environment = terraform.workspace
    azs = var.availability_zones[var.default_region]
    region = var.default_region
}

resource "aws_elb" "eureka_elb" {
  name               = "eureka-elb"
  availability_zones = ["${var.default_region}${var.default_az}"]

  listener {
    instance_port     = 8010
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8010/"
    interval            = 30
  }

  cross_zone_load_balancing   = true
  idle_timeout                = 200
  connection_draining         = true
  connection_draining_timeout = 200

  tags = {
    Name = "eureka-elb"
  }

  security_groups = [aws_security_group.mesos_security_group.id]
}