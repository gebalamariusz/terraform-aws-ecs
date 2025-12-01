# ------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ------------------------------------------------------------------------------

variable "name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "environment" {
  description = "Environment (e.g., dev, staging, prod)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where ECS instances will be deployed"
  type        = string
}

variable "instance_profile_arn" {
  description = "ARN of the IAM instance profile for ECS instances"
  type        = string
}

variable "capacity_providers" {
  description = <<-EOT
    Map of capacity providers to create. Each capacity provider creates:
    - Launch Template with specified instance type and security groups
    - Auto Scaling Group with specified subnet IDs and scaling configuration

    Example:
    {
      "controller" = {
        instance_type      = "t3.medium"
        security_group_ids = ["sg-xxx"]
        subnet_ids         = ["subnet-xxx"]
        min_size           = 1
        max_size           = 1
        desired_capacity   = 1
      }
    }
  EOT
  type = map(object({
    instance_type      = string
    security_group_ids = list(string)
    subnet_ids         = list(string)
    min_size           = optional(number, 0)
    max_size           = optional(number, 1)
    desired_capacity   = optional(number, 1)
    managed_scaling    = optional(bool, false)
    target_capacity    = optional(number, 100)
  }))

  validation {
    condition     = length(var.capacity_providers) > 0
    error_message = "At least one capacity provider must be defined."
  }
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES
# ------------------------------------------------------------------------------

variable "container_insights" {
  description = "Enable CloudWatch Container Insights for the cluster"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags for all resources"
  type        = map(string)
  default     = {}
}
