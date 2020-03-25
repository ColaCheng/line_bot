variable "my_env" {
  description = "web environment to deploy, also used as terraform workspace"
}

variable "stack_prefix" {
  description = "prefix for the stack, can be different from env"
}

variable "aws_region" {
  description = "The AWS region to create things in."
}

variable "aws_amis" {
  type        = "map"
  description = "Map of region -> aws AMI id"
}

variable "web_instance_role_name" {
  description = "Role name to attach to web ec2 instances autoscaling group. Should have read only access to environment secrets."
  default     = ""
}

variable "vpc_id" {
  type        = "string"
  description = "vpc id"
}

variable "vpc_zone_identifier" {
  type        = "list"
  description = "List of subnet ids for vpc avaliability zones to use. Should match your availability_zones"
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

variable "cpu_util_target" {
  default     = 60.0
  description = "Target cpu utilization used for autoscaling"
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

variable "web_elb_sg_id" {
  description = "elb security group id to allow incoming traffic for okami"
}

variable "web_elb_name" {
  description = "elb id to register asg instances with elb"
}

variable "developer_cidr_blocks" {
  description = "list of cidr blocks that developers use to access web, these blocks will be whitelisted"
  type        = "list"
  default     = []
}

variable "hosted_zone_id" {
  type        = "string"
  description = "ID of the hosted zone used for domain deployment, ex Z32I19ORDN2"
}

variable "hosted_zone_domain" {
  type        = "string"
  description = "top level domain used for the hosted zone"
}

variable "ipa_domain" {
  type        = "string"
  description = "the ipa managed domain for the instance dns"
}

variable "health_check_port" {
  default     = "4001"
  description = "The health check port"
}

variable "health_check_path" {
  default     = "/"
  description = "The health check path"
}

variable "enable_rolling_update" {
  default     = "false"
  description = "Enable/disable experimental rolling update feature. If disabled a new ASG is created for blue/green deployment"
}

variable "update_batch" {
  default     = 2
  description = "number of nodes to update at a time during rolling update"
}

variable "attach_loadbalancers" {
  default     = "true"
  description = "disable to allow updating autoscaling group without attaching it to the loadbalancers"
}
