variable "hosted_zone_id" {
  type        = "string"
  description = "ID of the hosted zone used for domain deployment, ex Z32I19ORDN2"
}
variable "base_host" {
  type        = "string"
  description = "base host used for the deployment"
}

variable "enabled" {
  default = "true"
}

variable "web_elb_dns_name" {
  description = "aws domain for web elb"
}

variable "web_elb_zone_id" {
  description = "zone id for web elb"
}
