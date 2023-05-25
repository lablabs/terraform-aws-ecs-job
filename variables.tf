variable "aws_region" {
  description = "AWS region where the resources are provisioned"
  type        = string
  default     = "eu-central-1"
}

variable "aws_account_id" {
  description = "AWS account id"
  type        = string
  default     = ""
}

variable "ecr_repo_name" {
  type        = string
  description = "Name of the ECR repo that contains the Docker image of your cron job"
  default     = ""
}

variable "ecr_registry_id" {
  description = "Registry id of the ECR repo"
  type        = string
  default     = ""
}

variable "external_image" {
  description = "Full url path to image, e.g. hello-world (without tag)"
  type        = string
  default     = ""
}

variable "image_tag" {
  type        = string
  description = "Docker tag of the container that you want to run"
}

variable "ecs_cluster_name" {
  type        = string
  default     = ""
  description = "(Optional) Name of the ECS Cluster that you want to execute your cron job. Defaults to your task name if no value is supplied"
}

variable "task_cpu" {
  type        = number
  default     = 1024
  description = "CPU units to allocate to your job (vCPUs * 1024)"
}

variable "task_memory" {
  type        = number
  default     = 2048
  description = "In MiB"
}

variable "env_variables" {
  type        = map(string)
  description = "The environment variables to pass to the container. This is a map of string: {name: value}"
  default     = {}
}

variable "subnet_ids" {
  type        = list(string)
  default     = []
  description = "Subnets where the job will be run"
}

variable "cloudwatch_schedule_expression" {
  type        = string
  default     = ""
  description = "AWS cron schedule expression"
}

variable "extra_container_defs" {
  type        = any
  default     = {}
  description = "Additional configuration that you want to add to your task definition (see https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html for all options)"
}

variable "task_role_arn" {
  type        = string
  default     = null
  description = "IAM role ARN for your task if it needs to access any AWS resources.  IMPORTANT: This must have an AssumeRolePolicy that includes the 'ecs-tasks.amazonaws.com' provider!!"
}

variable "ecs_task_execution_role_name" {
  type        = string
  default     = ""
  description = "If the default AWS ECSTaskExecutionRole is not sufficient for your needs, you can provide your own ECS Task Execution Role here. The module will attach a CloudWatch policy for logging purposes."
}
