### ELB
resource "aws_security_group" "web-elb-sg" {
  name        = "web_${var.stack_prefix}_elb"
  description = "Used in the terraform"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    env          = "${var.my_env}"
    stack_prefix = "${var.stack_prefix}"
  }
}

locals {
  default_web_elb_name = "web-${var.stack_prefix}"
}

resource "aws_elb" "web-elb" {
  name     = "${var.web_elb_name == "" ? local.default_web_elb_name : var.web_elb_name}"
  internal = "${var.private_environment}"

  # The same subnets as our instances
  subnets = "${var.subnets}"

  security_groups = [
    "${aws_security_group.web-elb-sg.id}",
  ]

  idle_timeout = 305

  connection_draining         = true
  connection_draining_timeout = 300

  listener {
    instance_port     = 4000
    instance_protocol = "tcp"
    lb_port           = 443
    lb_protocol       = "tcp"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = "${var.unhealthy_threshold}"
    timeout             = 5
    target              = "HTTP:${var.health_check_port}${var.health_check_path}"
    interval            = 10
  }

  tags = {
    env          = "${var.my_env}"
    stack_prefix = "${var.stack_prefix}"
  }
}

resource "aws_proxy_protocol_policy" "web" {
  load_balancer  = "${aws_elb.web-elb.name}"
  instance_ports = ["4000"]
}
