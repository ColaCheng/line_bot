# Specify the provider and access details
terraform {
  required_version = "~> 0.11"
}

provider "aws" {
  region  = "${var.aws_region}"
  version = "~> 2.54"
}

provider "null" {
  version = "~> 2.1"
}

provider "template" {
  version = "~> 2.1"
}

locals {
  stack_prefix = "${var.disable_workspace == 1 ?  var.stack_name : var.my_env }"
  base_host    = "${var.environment_domain_prefix}${var.hosted_zone_domain}"
}

module "lb-setup" {
  source              = "./modules/lb-setup"
  my_env              = "${var.my_env}"
  stack_prefix        = "${local.stack_prefix}"
  vpc_id              = "${var.vpc_id}"
  subnets             = "${var.subnets}"
  unhealthy_threshold = "${var.unhealthy_threshold}"
  health_check_port   = "${var.health_check_port}"
  health_check_path   = "${var.health_check_path}"
  base_host           = "${local.base_host}"
  private_environment = "${var.private_environment}"
  web_elb_name        = "${var.web_elb_name}"
  web_lb_timeout      = 300
}

module "domain-setup" {
  source           = "./modules/domain-setup"
  enabled          = "${var.enable_domain_setup}"
  hosted_zone_id   = "${var.hosted_zone_id}"
  base_host        = "${local.base_host}"
  web_elb_dns_name = "${module.lb-setup.web_elb_dns_name}"
  web_elb_zone_id  = "${module.lb-setup.web_elb_zone_id}"
}

module "cloudformation_setup" {
  source                 = "./modules/cloudformation_setup"
  my_env                 = "${var.my_env}"
  stack_prefix           = "${local.stack_prefix}"
  aws_region             = "${var.aws_region}"
  aws_amis               = "${var.aws_amis}"
  asg_min                = "${var.asg_min}"
  asg_max                = "${var.asg_max}"
  asg_desired            = "${var.asg_desired}"
  spot_price             = "${var.spot_price}"
  web_instance_role_name = "${var.web_instance_role_name}"
  instance_type          = "${var.instance_type}"
  key_name               = "${var.key_name}"
  vpc_zone_identifier    = "${var.vpc_zone_identifier}"
  web_elb_sg_id          = "${module.lb-setup.web_elb_sg_id}"
  web_elb_name           = "${module.lb-setup.web_elb_name}"
  developer_cidr_blocks  = "${var.developer_cidr_blocks}"
  hosted_zone_id         = "${var.hosted_zone_id}"
  hosted_zone_domain     = "${var.hosted_zone_domain}"
  ipa_domain             = "${var.ipa_domain == "" ? var.hosted_zone_domain : var.ipa_domain}"
  vpc_id                 = "${var.vpc_id}"
  health_check_port      = "${var.health_check_port}"
  health_check_path      = "${var.health_check_path}"
  cpu_util_target        = "${var.cpu_util_target}"
  enable_rolling_update  = "${var.enable_rolling_update}"
  attach_loadbalancers   = "${var.attach_loadbalancers}"
}
