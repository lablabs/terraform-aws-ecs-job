locals {
  ecs_cluster_arn = var.ecs_cluster_name != "" ? data.aws_ecs_cluster.existing[0].arn : aws_ecs_cluster.this[0].arn
  container_definitions = [
    merge({
      "name" : module.label.id,
      "image" : "${var.external_image == "" ? data.aws_ecr_repository.existing[0].repository_url : var.external_image}:${var.image_tag}",
      "cpu" : var.task_cpu / 1024,
      "memoryReservation" : var.task_memory,
      "essential" : true,
      "environment" : [
        for k, v in var.env_variables : {
          name  = k
          value = v
        }
      ],
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-region" : var.aws_region,
          "awslogs-group" : module.label.id,
          "awslogs-stream-prefix" : module.label.id,
          "awslogs-create-group" : "true"
        }
      }
    }, var.extra_container_defs)
  ]
}

resource "aws_ecs_cluster" "this" {
  count = var.ecs_cluster_name == "" ? 1 : 0
  name  = module.label.id

  setting {
    name  = "containerInsights" # https://docs.bridgecrew.io/docs/bc_aws_logging_11
    value = "enabled"
  }
}

data "aws_ecs_cluster" "existing" {
  count        = var.ecs_cluster_name != "" ? 1 : 0
  cluster_name = var.ecs_cluster_name
}

data "aws_ecr_repository" "existing" {
  count       = var.external_image == "" ? 1 : 0
  name        = var.ecr_repo_name
  registry_id = var.ecr_registry_id
}

resource "aws_ecs_task_definition" "this" {
  family                   = module.label.id
  container_definitions    = jsonencode(local.container_definitions)
  task_role_arn            = var.task_role_arn
  execution_role_arn       = local.ecs_task_execution_role_arn
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = tostring(var.task_cpu)
  memory                   = tostring(var.task_memory)
}
