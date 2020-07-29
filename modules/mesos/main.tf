

data "template_file" "user_data" {
    template = file("${path.root}/userdata/mesos.tpl")

    vars = {
        default_region = var.region
    }
}

resource "aws_launch_configuration" "mesos_launch_config" {
    name = "mesos_${var.mesos_type}_lc_${terraform.workspace}_${var.cluster_id}"
    key_name = var.key_pair_name
    image_id = var.mesos_image_id
    iam_instance_profile = var.instance_profile_name
    security_groups = var.security_groups
    instance_type = var.instance_type
    user_data = base64encode(data.template_file.user_data.rendered)

    root_block_device {
        volume_type = "gp2"
        volume_size = 15
        delete_on_termination = true
    }

    depends_on = [var.instance_profile_name]
}

resource "aws_autoscaling_group" "mesos_asg" {
    name = "mesos_${var.mesos_type}_asg_${terraform.workspace}_${var.cluster_id}"
    availability_zones = var.azs
    launch_configuration = aws_launch_configuration.mesos_launch_config.name
    min_size = var.asg_min_size
    max_size = var.asg_max_size
    desired_capacity = var.asg_desired_capacity

    tag {
        key                 = "Name"
        value               = "mesos_${var.mesos_type}_asg_${terraform.workspace}_${var.cluster_id}"
        propagate_at_launch = true
    }
    tag {
        key                 = "Tier"
        value               = "mesos-${var.mesos_type}"
        propagate_at_launch = true
    }    
    tag {
        key                 = "ClusterId"
        value               = var.cluster_id
        propagate_at_launch = true
    }
    tag {
        key                 = "Mesos${var.mesos_type}Instance"
        value               = "mesos-${var.mesos_type}-${var.cluster_id}"
        propagate_at_launch = true
    } 
    tag {
        key                 = "Environment"
        value               = terraform.workspace
        propagate_at_launch = true
    }         
}
