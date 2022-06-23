module "ecs_jobs" {
  source = "../../"

  name          = "job-example"
  ecr_repo_name = "docker/library/hello-world"
  image_tag     = "latest"
}
