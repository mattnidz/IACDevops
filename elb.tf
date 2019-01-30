# locals  {
#   proxy_node_ids = "${compact(concat(aws_instance.appproxy.*.id, aws_instance.appproxy.*.id))}"
# }


## Network LoadBalancer which will allow loadbalancing between availabilty zones.
resource "aws_lb" "jenkins-console" {
  depends_on = [
    "aws_internet_gateway.devops_gw"
  ]

  name = "jenkins-console"
  load_balancer_type = "network"
  #  internal = "true"

  lifecycle  {
    create_before_destroy = true
  }

  tags = "${var.default_tags}"

  # The same availability zone as our instance
  subnets = [ "${aws_subnet.devops_public_subnet.*.id}" ]
}


resource "aws_lb_target_group" "jenkins-8080" {
  name = "${random_id.clusterid.hex}-jenkins-8080-tg"
  port = 8080
  protocol = "TCP"
  tags = "${var.default_tags}"
  vpc_id = "${aws_vpc.devops_vpc.id}"

  lifecycle  {
    create_before_destroy = false
  }

}

resource "aws_lb_target_group_attachment" "jenkins-8080" {
  count = "${var.jenkins["nodes"]}"
  target_group_arn = "${aws_lb_target_group.jenkins-8080.arn}"
  target_id = "${element(aws_instance.jenkins_master.*.id, count.index)}"
  # target_id = "${element(aws_network_interface.proxyvip.*.id, count.index)}"
  port = 8080
  lifecycle  {
    create_before_destroy = false
  }

}

#TODO: Add healthcheck once web application is more matured.
resource "aws_lb_listener" "jenkins-8080" {
  load_balancer_arn = "${aws_lb.jenkins-console.arn}"
  port = "8080"
  protocol = "TCP"

  default_action {
    target_group_arn = "${aws_lb_target_group.jenkins-8080.arn}"
    type = "forward"
  }

  lifecycle  {
    create_before_destroy = false
  }
}

