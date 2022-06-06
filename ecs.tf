locals {
  ecs_cluster_arn = var.ecs_cluster_name != "" ? data.aws_ecs_cluster.existing[0].arn : aws_ecs_cluster.this[0].arn
  container_definitions = [
    merge({
      "name" : var.task_name,
      "image" : "${data.aws_ecr_repository.existing.repository_url}:${var.image_tag}",
      "cpu" : var.task_cpu / 1024,
      "memoryReservation" : var.task_memory,
      "essential" : true,
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-region" : var.aws_region,
          "awslogs-group" : var.task_name,
          "awslogs-stream-prefix" : var.task_name,
          "awslogs-create-group" : "true"
        }
      }
    }, var.extra_container_defs)
  ]
}

resource "aws_ecs_cluster" "this" {
  count = var.ecs_cluster_name == "" ? 1 : 0
  name  = var.task_name
}

data "aws_ecs_cluster" "existing" {
  count        = var.ecs_cluster_name != "" ? 1 : 0
  cluster_name = var.ecs_cluster_name
}

data "aws_ecr_repository" "existing" {
  name = var.ecr_repo_name
}

resource "aws_ecs_task_definition" "this" {
  family                   = var.task_name
  container_definitions    = jsonencode(local.container_definitions)
  task_role_arn            = var.task_role_arn
  execution_role_arn       = local.ecs_task_execution_role_arn
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = tostring(var.task_cpu)
  memory                   = tostring(var.task_memory)
}