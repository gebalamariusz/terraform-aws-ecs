# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-11-28

### Added

- Initial release of AWS ECS Terraform module
- ECS cluster with Container Insights
- Flexible capacity providers via map configuration
- Launch Templates with ECS-optimized Amazon Linux 2023 AMI
- Auto Scaling Groups with instance tagging
- Support for managed scaling with target capacity
- Placement constraints via CapacityProvider instance tags
- Consistent naming with name prefix and environment
- Consistent tagging with `ManagedBy` and `Module` tags
- CI pipeline with terraform fmt, validate, tflint, and tfsec
- MIT License

[1.0.0]: https://github.com/gebalamariusz/terraform-aws-ecs/releases/tag/v1.0.0
