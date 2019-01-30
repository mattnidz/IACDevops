## Generate a new key if this is required for deployment to prevents resource collisions
resource "random_id" "clusterid" {
  byte_length = "2"
}

locals  {
  iam_ec2_instance_profile_id = "${var.existing_ec2_iam_instance_profile_name != "" ?
        var.existing_ec2_iam_instance_profile_name :
        element(concat(aws_iam_instance_profile.devops_ec2_instance_profile.*.id, list("")), 0)}"

  default_ami = "${var.ami}"
}


resource "aws_instance" "bastion" {
  count         = "${var.bastion["nodes"]}"
  key_name      = "${var.key_name}"
  ami           = "${var.bastion["ami"] != "" ? var.bastion["ami"] : local.default_ami }"
  instance_type = "${var.bastion["type"]}"
  subnet_id     = "${element(aws_subnet.devops_public_subnet.*.id, count.index)}"
  vpc_security_group_ids = [
    "${aws_security_group.default.id}",
    "${aws_security_group.bastion.id}"
  ]

  lifecycle  {
    create_before_destroy = true
  }
  
  availability_zone = "${format("%s%s", element(list(var.aws_region), count.index), element(var.azs, count.index))}"
  associate_public_ip_address = true

  root_block_device {
    volume_size = "${var.bastion["disk"]}"
    delete_on_termination = true
  }

  
  tags = "${merge(var.default_tags, map(
    "Name",  "${format("${var.instance_name}-${random_id.clusterid.hex}-bastion%02d", count.index + 1) }"
  ))}"
  user_data = <<EOF
#cloud-config
fqdn: ${format("${var.instance_name}-bastion%02d", count.index + 1)}.${random_id.clusterid.hex}.${var.private_domain}
users:
- default
manage_resolv_conf: true
resolv_conf:
  nameservers: [ ${cidrhost(element(aws_subnet.devops_private_subnet.*.cidr_block, count.index), 2)}]
  domain: ${random_id.clusterid.hex}.${var.private_domain}
  searchdomains:
  - ${random_id.clusterid.hex}.${var.private_domain}
EOF
}


# Jenkins Master Server
resource "aws_instance" "jenkins_master" {
  depends_on = [
    "aws_route_table_association.a"
  ]

  count         = "${var.jenkins["nodes"]}"
  key_name      = "${var.key_name}"
  ami           = "${var.bastion["ami"] != "" ? var.jenkins["ami"] : local.default_ami }"
  instance_type = "${var.jenkins["type"]}"

  ebs_optimized = "${var.jenkins["ebs_optimized"]}"
  root_block_device {
    volume_size = "${var.jenkins["disk"]}"
  }

  ebs_block_device {
    device_name       = "/dev/xvdx"
    volume_size       = "${var.jenkins["jenkins_vol"]}"
    volume_type       = "gp2"
  }

  network_interface {
    network_interface_id = "${element(aws_network_interface.jenkinsvip.*.id, count.index)}"
    device_index = 0
    
  }

  iam_instance_profile = "${local.iam_ec2_instance_profile_id}"

  tags = "${merge(
    var.default_tags,
    map("Name", "${format("${var.instance_name}-${random_id.clusterid.hex}-jenkins%02d", count.index + 1) }"),
    map("devops/jenkins/${random_id.clusterid.hex}", "${random_id.clusterid.hex}")
  )}"
  user_data = <<EOF
#cloud-config
packages:
- unzip
- python
- git
- wget
- vim
- dos2unix
rh_subscription:
  enable-repo: rhui-REGION-rhel-server-optional
write_files:
- path: /opt/app/bootstrap-node.sh
  permissions: '0755'
  encoding: b64
  content: ${base64encode(file("${path.module}/bootstrap-node.sh"))}
runcmd:
- dos2unix /opt/app/*
- /opt/app/bootstrap-node.sh
users:
- default
- name: jenkins
  groups: [ wheel ]
  sudo: [ "ALL=(ALL) NOPASSWD:ALL" ]
  shell: /bin/bash
fqdn: ${format("${var.instance_name}-jenkins%02d", count.index + 1)}.${random_id.clusterid.hex}.${var.private_domain}
manage_resolv_conf: true
resolv_conf:
  nameservers: [ ${cidrhost(element(aws_subnet.devops_private_subnet.*.cidr_block, count.index), 2)}]
  domain: ${random_id.clusterid.hex}.${var.private_domain}
  searchdomains:
  - ${random_id.clusterid.hex}.${var.private_domain}
EOF
}


resource "aws_network_interface" "jenkinsvip" {
  count           = "${var.jenkins["nodes"]}"
  subnet_id       = "${element(aws_subnet.devops_private_subnet.*.id, count.index)}"
  private_ips_count = 1
  

  lifecycle  {
    create_before_destroy = true
  }

  security_groups = [
    "${aws_security_group.default.id}",
    "${aws_security_group.jenkins.id}"
  ]

  tags = "${merge(var.default_tags, map(
    "Name", "${format("${var.instance_name}-${random_id.clusterid.hex}-jenkins%02d", count.index + 1) }"
  ))}"
}


output "Jenkins Console External URL" {
  value = "http://${var.user_provided_cert_dns != "" ? var.user_provided_cert_dns : aws_lb.jenkins-console.dns_name}:8080"
}
