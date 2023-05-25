module "ecs_jobs" {
  source = "../../"

  name           = "job-example"
  external_image = "hello-world"
  image_tag      = "latest"
}
