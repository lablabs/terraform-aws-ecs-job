locals {
  ecs_task_execution_role_arn  = var.ecs_task_execution_role_name != "" ? data.aws_iam_role.task_execution_role[0].arn : aws_iam_role.task_execution_role[0].arn
  ecs_task_execution_role_name = var.ecs_task_execution_role_name != "" ? data.aws_iam_role.task_execution_role[0].name : aws_iam_role.task_execution_role[0].name
  aws_account_id               = var.aws_account_id != "" ? var.aws_account_id : data.aws_caller_identity.current.account_id
  cloudwatch_log_group_arn     = "arn:aws:logs:${var.aws_region}:${local.aws_account_id}:log-group:${local.cloudwatch_log_group_name}:*"
}

# IAM Resources
# -------------
# 2 IAM roles:
# 1. A Task Execution role used to run the ECS task and log output to cloudwatch.  This can be overridden by the user if they are using a
#    non-default ECSTaskExecutionRole.
# 2. A second role used by Cloudwatch to launch the ECS task when the timer is triggered
#
# Users can add a 3rd role if the ECS Task needs to access AWS resources.

# Task Execution Role
# Includes essential ecs access and cloudwatch logging permissions
data "aws_iam_policy_document" "task_execution_assume_role" {
  statement {
    principals {
      type = "Service"
      identifiers = [
        "ecs-tasks.amazonaws.com"
      ]
    }
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
  }
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "task_execution_cloudwatch_access" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [local.cloudwatch_log_group_arn]
  }
}

data "aws_iam_role" "task_execution_role" {
  count = var.ecs_task_execution_role_name != "" ? 1 : 0

  name = var.ecs_task_execution_role_name
}

resource "aws_iam_role" "task_execution_role" {
  count = var.ecs_task_execution_role_name == "" ? 1 : 0

  name               = "${module.label.id}-execution"
  assume_role_policy = data.aws_iam_policy_document.task_execution_assume_role.json
}

resource "aws_iam_policy" "task_execution_logging_policy" {
  name   = "${module.label.id}-logging"
  policy = data.aws_iam_policy_document.task_execution_cloudwatch_access.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  count = var.ecs_task_execution_role_name == "" ? 1 : 0

  role       = local.ecs_task_execution_role_name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_cloudwatch_access" {
  role       = local.ecs_task_execution_role_name
  policy_arn = aws_iam_policy.task_execution_logging_policy.arn
}

# Cloudwatch execution role
data "aws_iam_policy_document" "cloudwatch_assume_role" {
  count = var.cloudwatch_schedule_expression != "" ? 1 : 0

  statement {
    principals {
      type = "Service"
      identifiers = [
        "events.amazonaws.com",
        "ecs-tasks.amazonaws.com",
      ]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "cloudwatch" {
  count = var.cloudwatch_schedule_expression != "" ? 1 : 0

  statement {
    effect    = "Allow"
    actions   = ["ecs:RunTask"]
    resources = [aws_ecs_task_definition.this.arn]
  }
  statement {
    effect  = "Allow"
    actions = ["iam:PassRole"]
    resources = concat([
      local.ecs_task_execution_role_arn
    ], var.task_role_arn != null ? [var.task_role_arn] : [])
  }
}

resource "aws_iam_role" "cloudwatch_role" {
  count = var.cloudwatch_schedule_expression != "" ? 1 : 0

  name               = "${module.label.id}-cloudwatch-execution"
  assume_role_policy = data.aws_iam_policy_document.cloudwatch_assume_role[0].json
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  count = var.cloudwatch_schedule_expression != "" ? 1 : 0

  role       = aws_iam_role.cloudwatch_role[0].name
  policy_arn = aws_iam_policy.cloudwatch[0].arn
}

resource "aws_iam_policy" "cloudwatch" {
  count = var.cloudwatch_schedule_expression != "" ? 1 : 0

  name   = "${module.label.id}-cloudwatch-execution"
  policy = data.aws_iam_policy_document.cloudwatch[0].json
}

data "aws_iam_policy_document" "cloudwatch_log_group_kms" {
  count = var.cloudwatch_log_group_kms_enabled ? 1 : 0

  #checkov:skip=CKV_AWS_109: Allow root and rds service to use kms key
  #checkov:skip=CKV_AWS_111: Allow root and rds service to use kms key
  statement {
    sid    = "Enable the account that owns the KMS key to manage it via IAM"
    effect = "Allow"

    actions = ["kms:*"]

    resources = ["*"]

    principals {
      type = "AWS"

      identifiers = [
        format("arn:aws:iam::%s:root", data.aws_caller_identity.current.account_id)
      ]
    }
  }

  statement {
    sid       = "Allow Cloudwatch log group to encrypt and decrypt with the KMS key"
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*",
    ]

    condition {
      test     = "ArnEquals"
      variable = "kms:EncryptionContext:aws:logs:arn"
      values   = ["arn:aws:logs:${var.aws_region}:${local.aws_account_id}:log-group:${local.cloudwatch_log_group_name}"]
    }

    principals {
      type        = "Service"
      identifiers = ["logs.${var.aws_region}.amazonaws.com"]
    }
  }
}
