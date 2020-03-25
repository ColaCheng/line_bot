output "web_elb_dns_name" {
  value = "${aws_elb.web-elb.dns_name}"
}

output "web_elb_zone_id" {
  value = "${aws_elb.web-elb.zone_id}"
}

output "web_elb_name" {
  value = "${aws_elb.web-elb.name}"
}

output "web_elb_sg_id" {
  value = "${aws_security_group.web-elb-sg.id}"
}