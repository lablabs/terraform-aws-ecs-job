data "aws_iam_policy_document" "task_failure" {

  statement {
    actions   = ["SNS:Publish"]
    effect    = "Allow"
    resources = [aws_sns_topic.task_failure.arn]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

resource "aws_sns_topic_policy" "task_failure" {
  arn    = aws_sns_topic.task_failure.arn
  policy = data.aws_iam_policy_document.task_failure.json
}

resource "aws_cloudwatch_event_rule" "task_failure" {
  name        = "${var.task_name}_task_failure"
  description = "Watch for ${var.task_name} tasks that exit with non zero exit codes"

  event_pattern = <<EOF
  {
    "source": [
      "aws.ecs"
    ],
    "detail-type": [
      "ECS Task State Change"
    ],
    "detail": {
      "lastStatus": [
        "STOPPED"
      ],
      "stoppedReason": [
        "Essential container in task exited"
      ],
      "containers": {
        "exitCode": [
          {"anything-but": 0}
        ]
      },
      "clusterArn": ["${local.ecs_cluster_arn}"],
      "taskDefinitionArn": ["${aws_ecs_task_definition.this.arn}"]
    }
  }
  EOF
}

resource "aws_sns_topic" "task_failure" {
  name = "${var.task_name}_task_failure"
}

resource "aws_cloudwatch_event_target" "sns_target" {
  rule  = aws_cloudwatch_event_rule.task_failure.name
  arn   = aws_sns_topic.task_failure.arn
  input = jsonencode({ "message" : "Task ${var.task_name} failed! Please check logs https://console.aws.amazon.com/cloudwatch/home#logsV2:log-groups/log-group/${var.task_name}" })
}
