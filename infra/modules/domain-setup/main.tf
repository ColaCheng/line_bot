### Domain setup
resource "aws_route53_record" "web_domain" {
  count   = "1"
  zone_id = "${var.hosted_zone_id}"
  name    = "${var.base_host}"
  type    = "A"

  alias {
    name                   = "${var.web_elb_dns_name}"
    zone_id                = "${var.web_elb_zone_id}"
    evaluate_target_health = true
  }
}