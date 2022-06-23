module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.6.0"

  name               = "ecs-job-vpc"
  cidr               = "10.0.0.0/16"
  azs                = ["eu-central-1a", "eu-central-1b"]
  private_subnets    = ["10.0.101.0/24", "10.0.102.0/24"]
  enable_nat_gateway = true
}

module "ecs_jobs" {
  source = "../../"

  name          = "job-example"
  ecr_repo_name = "docker/library/hello-world"
  image_tag     = "latest"
  subnet_ids    = module.vpc.private_subnets

  cloudwatch_schedule_expression = "cron(0 12 * * ? *)"
}
