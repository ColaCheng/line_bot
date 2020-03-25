variable "my_env" {
  description = "murano environment to deploy, also used as terraform workspace"
}

variable "stack_prefix" {
  description = "prefix for the stack, can be different from env"
}

variable "base_host" {
  description = "base host used for host based service routing"
}

variable "vpc_id" {
  description = "Vpc id used for murano ALB configuration"
}

variable "unhealthy_threshold" {
  default     = "2"
  description = "The load balancer unhealthy threshold"
}

variable "health_check_port" {
  description = "The health check port"
}

variable "health_check_path" {
  description = "The health check path"
}

variable "private_environment" {
  description = "disable public loadbalancer access"
  default     = false
}

variable "web_elb_name" {
  description = "custom name for web ELB"
  default     = ""
}

variable "subnets" {
  type        = "list"
  description = "List of subnet ids for vpc avaliability zones to use. Should match your availability_zones and be public"
}

variable "web_lb_timeout" {
  description = "web lb idle timeout in seconds, defaults to 60 sec"
  default     = 60
}
