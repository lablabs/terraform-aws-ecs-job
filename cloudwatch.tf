# Cloudwatch trigger
# ------------------
resource "aws_cloudwatch_event_rule" "event_rule" {
  count = var.cloudwatch_schedule_expression != "" ? 1 : 0

  name                = module.label.id
  schedule_expression = var.cloudwatch_schedule_expression
}

# Failure notification configuration (using Cloudwatch)
# -----------------------------------------------------
# Event rule that sends a message to an SNS Topic every time the task fails with a non-0 error code

resource "aws_cloudwatch_event_target" "ecs_scheduled_task" {
  count = var.cloudwatch_schedule_expression != "" ? 1 : 0

  rule      = aws_cloudwatch_event_rule.event_rule[0].name
  target_id = module.label.id
  arn       = local.ecs_cluster_arn
  role_arn  = aws_iam_role.cloudwatch_role[0].arn

  ecs_target {
    launch_type         = "FARGATE"
    platform_version    = "LATEST"
    task_count          = 1
    task_definition_arn = aws_ecs_task_definition.this.arn
    network_configuration {
      subnets = var.subnet_ids
    }
  }
}
