// Cloudwatch trigger
// ------------------
resource "aws_cloudwatch_event_rule" "event_rule" {
  name                = var.task_name
  schedule_expression = var.cloudwatch_schedule_expression
}

// Failure notification configuration (using Cloudwatch)
// -----------------------------------------------------
// We create an event rule that sends a message to an SNS Topic every time the task fails with a non-0 error code
// We also configure the

resource "aws_cloudwatch_event_target" "ecs_scheduled_task" {
  rule      = aws_cloudwatch_event_rule.event_rule.name
  target_id = var.task_name
  arn       = local.ecs_cluster_arn
  role_arn  = aws_iam_role.cloudwatch_role.arn

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
