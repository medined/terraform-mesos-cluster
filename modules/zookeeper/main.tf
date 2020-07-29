
data "template_file" "user_data" {
    template = file("${path.root}/userdata/zookeeper.tpl")

    vars = {
        default_region = var.region
    }
}

resource "aws_instance" "zookeeper" {
    #subnet_id = var.subnet_id
    iam_instance_profile = var.instance_profile_name
    instance_type = var.instance_type
    ami = var.image_id
    key_name = var.key_pair_name
    security_groups = var.security_groups
    user_data = base64encode(data.template_file.user_data.rendered)
    //user_data = data.template_file.user_data.rendered
    tags = {
        Name = "zookeeper_${terraform.workspace}_${var.cluster_id}"
        ClusterId = var.cluster_id
        ZookeeperInstance = "zookeeper-${var.cluster_id}"
        Environment = terraform.workspace
        Tier = "zookeeper"
    }
}