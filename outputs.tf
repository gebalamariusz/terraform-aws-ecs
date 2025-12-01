# ------------------------------------------------------------------------------
# CLUSTER OUTPUTS
# ------------------------------------------------------------------------------

output "cluster_id" {
  description = "ID of the ECS cluster"
  value       = aws_ecs_cluster.this.id
}

output "cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = aws_ecs_cluster.this.arn
}

output "cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.this.name
}

# ------------------------------------------------------------------------------
# CAPACITY PROVIDER OUTPUTS
# ------------------------------------------------------------------------------

output "capacity_provider_names" {
  description = "Map of capacity provider keys to their names"
  value       = { for k, v in aws_ecs_capacity_provider.this : k => v.name }
}

output "capacity_provider_arns" {
  description = "Map of capacity provider keys to their ARNs"
  value       = { for k, v in aws_ecs_capacity_provider.this : k => v.arn }
}

# ------------------------------------------------------------------------------
# LAUNCH TEMPLATE OUTPUTS
# ------------------------------------------------------------------------------

output "launch_template_ids" {
  description = "Map of capacity provider keys to launch template IDs"
  value       = { for k, v in aws_launch_template.this : k => v.id }
}

# ------------------------------------------------------------------------------
# AUTO SCALING GROUP OUTPUTS
# ------------------------------------------------------------------------------

output "autoscaling_group_names" {
  description = "Map of capacity provider keys to ASG names"
  value       = { for k, v in aws_autoscaling_group.this : k => v.name }
}

output "autoscaling_group_arns" {
  description = "Map of capacity provider keys to ASG ARNs"
  value       = { for k, v in aws_autoscaling_group.this : k => v.arn }
}
