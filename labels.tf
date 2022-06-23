module "label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  namespace   = var.namespace
  environment = var.environment
  stage       = var.stage
  name        = var.name
  attributes  = var.attributes

  tags = merge(
    var.tags,
    { "terraform-module" = "terraform-aws-ecs-job" }
  )

  context = var.context
}
