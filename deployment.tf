# The primary use-case for the null resource is as a do-nothing container
# for arbitrary actions taken by a provisioner.
resource "null_resource" "codedeploy_deployment" {
  count = var.deployment_controller == "CODE_DEPLOY" ? 1 : 0

  depends_on = [aws_codedeploy_app.ecs, aws_ecs_task_definition.default]

  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    image               = var.image
    task_definition_arn = aws_ecs_task_definition.default[0].arn
  }

  provisioner "local-exec" {
    command = <<-EOT
    aws configure set default.region ${data.aws_region.current.name} && \
    aws deploy create-deployment \
      --application-name ${aws_codedeploy_app.ecs[0].name} \
      --deployment-group-name ${var.name} \
      --deployment-config-name CodeDeployDefault.ECSAllAtOnce \
      --description DeploymentFromTerraform || \
    echo "Deployment already in progress"
    EOT
  }
}

resource "null_resource" "fargate_deployment" {
  count = var.deployment_controller == "ECS" ? 1 : 0

  depends_on = [aws_ecs_task_definition.default]

  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    image               = var.image
    task_definition_arn = aws_ecs_task_definition.default[0].arn
  }

  provisioner "local-exec" {
    command = <<-EOT
    aws configure set default.region ${data.aws_region.current.name} && \
    aws ecs update-service \
      --service ${var.name} \
      --cluster ${var.cluster_name} \
      --task-definition ${aws_ecs_task_definition.default[0].arn} \
      --force-new-deployment || \
    echo "Deployment already in progress"
    EOT
  }
}
