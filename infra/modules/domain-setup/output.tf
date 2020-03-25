# output "apps_fqdn" {
#   value = "${element(concat(aws_route53_record.apps.*.fqdn, list("")),0)}"
# }

# output "interal_api_fqdn" {
#   value = "${element(concat(aws_route53_record.web-wildcard-internal-api.*.fqdn, list("")),0)}"
# }

# output "base_web_fqdn" {
#   value = "${element(concat(aws_route53_record.base-web.*.fqdn, list("")),0)}"
# }
