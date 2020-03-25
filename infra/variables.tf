variable "my_env" {
  description = "environment to deploy, also used as terraform workspace"
}

variable "stack_name" {
  default     = "default"
  description = "prefix for the stack, can be different from env"
}

variable "aws_region" {
  description = "The AWS region to create things in."
}

variable "hosted_zone_id" {
  type        = "string"
  description = "ID of the hosted zone used for domain deployment, ex Z32I19ORDN2"
}

variable "hosted_zone_domain" {
  type        = "string"
  description = "top level domain used for the hosted zone"
}

variable "environment_domain_prefix" {
  type        = "string"
  description = "prefix to add to the hosted_zone_domain for this environment, ex 'env.'"
}

variable "aws_amis" {
  type        = "map"
  description = "Map of region -> aws AMI id"
  default     = {}
}

variable "vpc_id" {
  description = "Vpc id used for ALB configuration"
}

variable "vpc_zone_identifier" {
  type        = "list"
  description = "List of subnet ids for vpc avaliability zones to use. Can be private and will be used for ASG setup. Should match your availability_zones"
}

variable "subnets" {
  type        = "list"
  description = "List of subnet ids for vpc avaliability zones to use. Should match your availability_zones and be public"
}

variable "key_name" {
  description = "Name of AWS key pair"
}

variable "instance_type" {
  description = "AWS instance type"
}

variable "spot_price" {
  description = "Optional Spot price to use for launch-configuration. empty == use on-demand price"
  default     = ""
}

variable "asg_min" {
  description = "Min numbers of servers in ASG"
}

variable "asg_max" {
  description = "Max numbers of servers in ASG"
}

variable "asg_desired" {
  description = "Desired numbers of servers in ASG"
}

variable "developer_cidr_blocks" {
  description = "list of cidr blocks that developers use to access, these blocks will be whitelisted"
  type        = "list"
  default     = []
}

variable "disable_workspace" {
  default     = false
  description = "Disable workspace check, use multiple backend instead"
}

variable "ipa_domain" {
  default     = ""
  type        = "string"
  description = "the ipa managed domain for the instance dns. If empty, default to the hosted_zone_domain"
}

variable "unhealthy_threshold" {
  default     = "2"
  description = "The load balancer unhealthy threshold"
}

variable "health_check_port" {
  default     = "4001"
  description = "The health check port"
}

variable "health_check_path" {
  default     = "/"
  description = "The health check path"
}

variable "private_environment" {
  description = "disable public loadbalancer access"
  default     = false
}

variable "enable_domain_setup" {
  description = "enable automatic domain setup"
  default     = "true"
}

variable "cpu_util_target" {
  default     = 60.0
  description = "Target cpu utilization used for autoscaling"
}

variable "enable_rolling_update" {
  default     = "false"
  description = "Enable/disable rolling experimental update feature. If disabled a new ASG is created for blue/green deployment"
}

variable "attach_loadbalancers" {
  default     = "true"
  description = "disable to allow updating autoscaling group without attaching it to the loadbalancers"
}

variable "web_elb_name" {
  description = "custom name for web ELB"
  default     = ""
}

variable "web_instance_role_name" {
  description = "Role name to attach to ec2 instances autoscaling group. Should have read only access to environment secrets."
  default     = ""
}
