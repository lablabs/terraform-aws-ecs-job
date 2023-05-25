# Scheduled task example

The code in this example shows how to use the module to create an ECS task and CloudWatch Event Rule to run the task automatically.

Define `subnet_ids` and `cloudwatch_schedule_expression` variables to schedule running ECS Task automatically.

[Schedule Expressions for CloudWatch Event Rules | AWS docs](https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html)

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ecs_jobs"></a> [ecs\_jobs](#module\_ecs\_jobs) | ../../ | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | 3.6.0 |

## Resources

No resources.

## Inputs

No inputs.

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
