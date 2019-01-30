resource "aws_route53_zone" "devops_private" {
  name = "${random_id.clusterid.hex}.${var.private_domain}"
  vpc_id = "${aws_vpc.devops_vpc.id}"
  # force_destroy = "true"
  lifecycle  {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "jenkins" {
  // same number of records as instances
  count         = "${var.jenkins["nodes"]}"
  zone_id       = "${aws_route53_zone.devops_private.zone_id}"
  name = "${format("${var.instance_name}-jenkins%02d", count.index + 1) }"
  type = "A"
  ttl = "300"
  // matches up record N to instance N
  records = ["${element(aws_instance.jenkins_master.*.private_ip, count.index)}"]
  //records = ["${element(aws_network_interface.jenkinsvip.*.private_ip, count.index)}"]
  lifecycle  {
    create_before_destroy = true
  }
}
