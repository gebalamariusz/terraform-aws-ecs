# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.x     | :white_check_mark: |

## Reporting a Vulnerability

If you discover a security vulnerability in this module, please report it responsibly:

1. **Do not** open a public GitHub issue for security vulnerabilities
2. Email the maintainer directly at: security@haitmg.pl
3. Include detailed information about the vulnerability
4. Allow reasonable time for a fix before public disclosure

## Security Best Practices

When using this module:

- Use private subnets for ECS instances
- Configure appropriate security groups to restrict access
- Use IAM roles with least privilege for EC2 instances
- Enable Container Insights for monitoring
- Use VPC endpoints for ECS, ECR, and CloudWatch
- Regularly update ECS-optimized AMI for security patches
- Use encrypted EBS volumes for sensitive workloads
- Enable ECS execute command logging for audit trails
