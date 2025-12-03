# AWS ECS Terraform Module

[![Terraform Registry](https://img.shields.io/badge/Terraform%20Registry-gebalamariusz%2Fecs%2Faws-blue?logo=terraform)](https://registry.terraform.io/modules/gebalamariusz/ecs/aws)
[![CI](https://github.com/gebalamariusz/terraform-aws-ecs/actions/workflows/ci.yml/badge.svg)](https://github.com/gebalamariusz/terraform-aws-ecs/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/gebalamariusz/terraform-aws-ecs?display_name=tag&sort=semver)](https://github.com/gebalamariusz/terraform-aws-ecs/releases)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.7-purple.svg)](https://www.terraform.io/)

Terraform module to create an ECS cluster with EC2 capacity providers.

This module is designed to work seamlessly with [terraform-aws-vpc](https://github.com/gebalamariusz/terraform-aws-vpc), [terraform-aws-subnets](https://github.com/gebalamariusz/terraform-aws-subnets), and [terraform-aws-security-group](https://github.com/gebalamariusz/terraform-aws-security-group) modules.

## Features

- Creates ECS cluster with Container Insights
- Flexible capacity providers (define as many as needed)
- Auto Scaling Groups with ECS-optimized Amazon Linux 2023 AMI
- Launch Templates with automatic ECS cluster registration
- Support for managed scaling (optional)
- Instance tagging for placement constraints
- Consistent naming and tagging conventions

## Usage

### Basic usage with single capacity provider

\`\`\`hcl
module "ecs" {
  source  = "gebalamariusz/ecs/aws"
  version = "~> 1.0"

  name        = "my-app"
  environment = "prod"

  vpc_id               = module.vpc.vpc_id
  instance_profile_arn = aws_iam_instance_profile.ecs.arn

  capacity_providers = {
    "default" = {
      instance_type      = "t3.medium"
      security_group_ids = [aws_security_group.ecs.id]
      subnet_ids         = module.subnets.private_subnet_ids
      min_size           = 1
      max_size           = 3
      desired_capacity   = 2
    }
  }

  tags = var.tags
}
\`\`\`

### Jenkins-style setup with separate controller and build capacity

\`\`\`hcl
module "ecs" {
  source  = "gebalamariusz/ecs/aws"
  version = "~> 1.0"

  name        = "jenkins"
  environment = "dev"

  vpc_id               = module.vpc.vpc_id
  instance_profile_arn = aws_iam_instance_profile.ecs.arn

  capacity_providers = {
    "controller" = {
      instance_type      = "t3.medium"
      security_group_ids = [module.security_groups.security_group_ids["ecs"]]
      subnet_ids         = [module.subnets.subnet_ids_by_tier["application"][0]]
      min_size           = 1
      max_size           = 1
      desired_capacity   = 1
    }
    "build" = {
      instance_type      = "t3.large"
      security_group_ids = [module.security_groups.security_group_ids["agent"]]
      subnet_ids         = [module.subnets.subnet_ids_by_tier["application"][1]]
      min_size           = 1
      max_size           = 1
      desired_capacity   = 1
    }
  }

  tags = var.tags
}
\`\`\`

### With managed scaling (auto-scale based on ECS demand)

\`\`\`hcl
module "ecs" {
  source  = "gebalamariusz/ecs/aws"
  version = "~> 1.0"

  name        = "workers"
  environment = "prod"

  vpc_id               = module.vpc.vpc_id
  instance_profile_arn = aws_iam_instance_profile.ecs.arn

  capacity_providers = {
    "workers" = {
      instance_type      = "t3.xlarge"
      security_group_ids = [aws_security_group.workers.id]
      subnet_ids         = module.subnets.private_subnet_ids
      min_size           = 0
      max_size           = 10
      desired_capacity   = 0
      managed_scaling    = true   # ECS will scale ASG based on task demand
      target_capacity    = 80     # Target 80% utilization
    }
  }

  tags = var.tags
}
\`\`\`

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the ECS cluster | \`string\` | n/a | yes |
| environment | Environment (e.g., dev, staging, prod) | \`string\` | n/a | yes |
| vpc_id | VPC ID where ECS instances will be deployed | \`string\` | n/a | yes |
| instance_profile_arn | ARN of the IAM instance profile for ECS instances | \`string\` | n/a | yes |
| capacity_providers | Map of capacity providers to create | \`map(object)\` | n/a | yes |
| container_insights | Enable CloudWatch Container Insights | \`bool\` | \`true\` | no |
| tags | Additional tags for all resources | \`map(string)\` | \`{}\` | no |

### Capacity Provider Object

| Attribute | Description | Type | Default |
|-----------|-------------|------|---------|
| instance_type | EC2 instance type | \`string\` | n/a |
| security_group_ids | List of security group IDs | \`list(string)\` | n/a |
| subnet_ids | List of subnet IDs for ASG | \`list(string)\` | n/a |
| min_size | Minimum ASG size | \`number\` | \`0\` |
| max_size | Maximum ASG size | \`number\` | \`1\` |
| desired_capacity | Desired ASG capacity | \`number\` | \`1\` |
| managed_scaling | Enable ECS managed scaling | \`bool\` | \`false\` |
| target_capacity | Target capacity percentage for managed scaling | \`number\` | \`100\` |

## Outputs

| Name | Description |
|------|-------------|
| cluster_id | ID of the ECS cluster |
| cluster_arn | ARN of the ECS cluster |
| cluster_name | Name of the ECS cluster |
| capacity_provider_names | Map of capacity provider keys to their names |
| capacity_provider_arns | Map of capacity provider keys to their ARNs |
| launch_template_ids | Map of capacity provider keys to launch template IDs |
| autoscaling_group_names | Map of capacity provider keys to ASG names |
| autoscaling_group_arns | Map of capacity provider keys to ASG ARNs |

## Using Placement Constraints

Each capacity provider tags its instances with \`CapacityProvider = <key>\`. Use this in ECS task definitions:

\`\`\`hcl
resource "aws_ecs_task_definition" "controller" {
  # ...

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:CapacityProvider == controller"
  }
}
\`\`\`

## License

MIT
