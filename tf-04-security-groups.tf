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
