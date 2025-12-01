# ------------------------------------------------------------------------------
# LOCAL VALUES
# ------------------------------------------------------------------------------

locals {
  cluster_name = "${var.name}-${var.environment}"

  common_tags = merge(
    var.tags,
    {
      ManagedBy = "terraform"
      Module    = "terraform-aws-ecs"
    }
  )
}

# ------------------------------------------------------------------------------
# DATA SOURCES
# ------------------------------------------------------------------------------

data "aws_region" "current" {}

data "aws_ssm_parameter" "ecs_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2023/recommended/image_id"
}

# ------------------------------------------------------------------------------
# ECS CLUSTER
# ------------------------------------------------------------------------------

resource "aws_ecs_cluster" "this" {
  name = local.cluster_name

  setting {
    name  = "containerInsights"
    value = var.container_insights ? "enabled" : "disabled"
  }

  tags = merge(local.common_tags, {
    Name = local.cluster_name
  })
}

# ------------------------------------------------------------------------------
# LAUNCH TEMPLATES
# ------------------------------------------------------------------------------

resource "aws_launch_template" "this" {
  for_each = var.capacity_providers

  name_prefix   = "${local.cluster_name}-${each.key}-"
  image_id      = data.aws_ssm_parameter.ecs_ami.value
  instance_type = each.value.instance_type

  iam_instance_profile {
    arn = var.instance_profile_arn
  }

  vpc_security_group_ids = each.value.security_group_ids

  user_data = base64encode(<<-EOF
    #!/bin/bash
    echo "ECS_CLUSTER=${local.cluster_name}" >> /etc/ecs/ecs.config
    echo "ECS_ENABLE_CONTAINER_METADATA=true" >> /etc/ecs/ecs.config

    # Tag instance for ECS placement constraints
    INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
    aws ec2 create-tags --resources $INSTANCE_ID --tags Key=CapacityProvider,Value=${each.key} --region ${data.aws_region.current.id}
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = merge(local.common_tags, {
      Name             = "${local.cluster_name}-${each.key}"
      CapacityProvider = each.key
    })
  }

  tag_specifications {
    resource_type = "volume"
    tags = merge(local.common_tags, {
      Name = "${local.cluster_name}-${each.key}"
    })
  }

  tags = merge(local.common_tags, {
    Name = "${local.cluster_name}-${each.key}-lt"
  })
}

# ------------------------------------------------------------------------------
# AUTO SCALING GROUPS
# ------------------------------------------------------------------------------

resource "aws_autoscaling_group" "this" {
  for_each = var.capacity_providers

  name                = "${local.cluster_name}-${each.key}"
  desired_capacity    = each.value.desired_capacity
  max_size            = each.value.max_size
  min_size            = each.value.min_size
  vpc_zone_identifier = each.value.subnet_ids

  launch_template {
    id      = aws_launch_template.this[each.key].id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${local.cluster_name}-${each.key}"
    propagate_at_launch = true
  }

  tag {
    key                 = "CapacityProvider"
    value               = each.key
    propagate_at_launch = true
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = "true"
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = local.common_tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ------------------------------------------------------------------------------
# ECS CAPACITY PROVIDERS
# ------------------------------------------------------------------------------

resource "aws_ecs_capacity_provider" "this" {
  for_each = var.capacity_providers

  name = "${local.cluster_name}-${each.key}"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.this[each.key].arn
    managed_termination_protection = "DISABLED"

    managed_scaling {
      status          = each.value.managed_scaling ? "ENABLED" : "DISABLED"
      target_capacity = each.value.target_capacity
    }
  }

  tags = merge(local.common_tags, {
    Name = "${local.cluster_name}-${each.key}"
  })
}

resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name = aws_ecs_cluster.this.name

  capacity_providers = [for k, v in aws_ecs_capacity_provider.this : v.name]
}
