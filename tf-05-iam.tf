# ------------------------------------------------------------------------------------
# Instance profile used across all Mesos components
# ------------------------------------------------------------------------------------

data "aws_iam_policy_document" "instance_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "mesos_ec2_role" {
  name               = "mesos_ec2_role_${terraform.workspace}"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.instance_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "s3_full_attachment" {
  role       = aws_iam_role.mesos_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
resource "aws_iam_role_policy_attachment" "ec2_full_attachment" {
  role       = aws_iam_role.mesos_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_instance_profile" "mesos_ec2_instance_profile" {
  name = "mesos_ec2_instance_profile_${terraform.workspace}"
  role = aws_iam_role.mesos_ec2_role.name
}
