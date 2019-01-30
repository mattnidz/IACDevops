
resource "aws_security_group" "default" {
  name = "devops_default_sg-${random_id.clusterid.hex}"
  description = "Default security group that allows inbound and outbound traffic from all instances in the VPC"
  vpc_id = "${aws_vpc.devops_vpc.id}"

  ingress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["${aws_vpc.devops_vpc.cidr_block}"]
    self        = true
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    self        = true
  }

  lifecycle  {
    create_before_destroy = true
  }

  tags = "${merge(
    var.default_tags,
    map("Name", "devops-default-sg-${random_id.clusterid.hex}"),
    map("devops/bastion/${random_id.clusterid.hex}", "${random_id.clusterid.hex}")
  )}"
}

resource "aws_security_group_rule" "bastion-22-ingress" {
  count = "${var.bastion["nodes"] > 0 ? length(var.allowed_cidr_bastion_22) : 0}"
  type = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = [
    "${element(var.allowed_cidr_bastion_22, count.index)}"
  ]
  lifecycle  {
    create_before_destroy = true
  }
  security_group_id = "${aws_security_group.bastion.id}"
}

resource "aws_security_group_rule" "bastion-22-egress" {
  count = "${var.bastion["nodes"] > 0 ? 1 : 0}"
  type = "egress"
  from_port   = "0"
  to_port     = "0"
  protocol    = "-1"
  cidr_blocks = [
    "0.0.0.0/0"
  ]

  lifecycle  {
    create_before_destroy = true
  }

  security_group_id = "${aws_security_group.bastion.id}"
}

resource "aws_security_group" "bastion" {
  count = "${var.bastion["nodes"] > 0 ? 1 : 0}"
  name = "devops-bastion-${random_id.clusterid.hex}"
  description = "allow SSH"
  vpc_id = "${aws_vpc.devops_vpc.id}"

  lifecycle  {
    create_before_destroy = true
  }

  tags = "${merge(
    var.default_tags,
    map("Name", "devops-bastion-${random_id.clusterid.hex}")
  )}"
}

resource "aws_security_group" "jenkins" {
  name = "devops-jenkins-${random_id.clusterid.hex}"
  description = "devops ${random_id.clusterid.hex} jenkins nodes"
  vpc_id = "${aws_vpc.devops_vpc.id}"

  lifecycle  {
    create_before_destroy = true
  }

  tags = "${merge(
    var.default_tags,
    map("Name", "devops-jenkins-${random_id.clusterid.hex}")
  )}"
}

resource "aws_security_group_rule" "jenkins-egress" {
  type = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = [
    "0.0.0.0/0"
  ]

  lifecycle  {
    create_before_destroy = true
  }

  security_group_id = "${aws_security_group.jenkins.id}"
}

resource "aws_security_group_rule" "jenkins-8080-ngw" {
    count = "${length(var.azs)}"
    type = "ingress"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["${element(aws_eip.devops_ngw_eip.*.public_ip, count.index)}/32"]
    security_group_id = "${aws_security_group.jenkins.id}"

    lifecycle  {
      create_before_destroy = true
    }

    description = "allow devops to contact itself on console endpoint over the nat gateway"
}

resource "aws_security_group_rule" "jenkins-8080-ingress" {
  count = "${length(var.allowed_cidr_jenkins)}"
  type = "ingress"
  from_port   = 8080
  to_port     = 8080
  protocol    = "tcp"
  cidr_blocks = [
    "${element(var.allowed_cidr_jenkins, count.index)}"
  ]

  lifecycle  {
    create_before_destroy = true
  }
  
  security_group_id = "${aws_security_group.jenkins.id}"
}



resource "aws_security_group_rule" "jenkins-443-ngw" {
    count = "${length(var.azs)}"
    type = "ingress"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${element(aws_eip.devops_ngw_eip.*.public_ip, count.index)}/32"]
    security_group_id = "${aws_security_group.jenkins.id}"

    lifecycle  {
      create_before_destroy = true
    }

    description = "allow devops to contact itself on console endpoint over the nat gateway"
}

resource "aws_security_group_rule" "jenkins-443-ingress" {
  count = "${length(var.allowed_cidr_jenkins)}"
  type = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = [
    "${element(var.allowed_cidr_jenkins, count.index)}"
  ]

  lifecycle  {
    create_before_destroy = true
  }
  
  security_group_id = "${aws_security_group.jenkins.id}"
}


resource "aws_security_group_rule" "jenkins-49187-ngw" {
    count = "${length(var.azs)}"
    type = "ingress"
    from_port   = 49187
    to_port     = 49187
    protocol    = "tcp"
    cidr_blocks = ["${element(aws_eip.devops_ngw_eip.*.public_ip, count.index)}/32"]
    security_group_id = "${aws_security_group.jenkins.id}"

    lifecycle  {
      create_before_destroy = true
    }

    description = "allow devops to contact itself on console endpoint over the nat gateway"
}

resource "aws_security_group_rule" "jenkins-49187-ingress" {
  count = "${length(var.allowed_cidr_jenkins)}"
  type = "ingress"
  from_port   = 49187
  to_port     = 49187
  protocol    = "tcp"
  cidr_blocks = [
    "${element(var.allowed_cidr_jenkins, count.index)}"
  ]

  lifecycle  {
    create_before_destroy = true
  }
  
  security_group_id = "${aws_security_group.jenkins.id}"
}