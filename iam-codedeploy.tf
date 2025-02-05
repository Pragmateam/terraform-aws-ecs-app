resource "aws_iam_role" "codedeploy_service" {

  count = var.create_iam_codedeployrole == true ? 1 : 0

  name = var.iam_codedeployrolename != null ? var.iam_codedeployrolename : "codedeploy-service-${var.cluster_name}-${var.name}-${data.aws_region.current.name}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "codedeploy.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "codedeploy_service" {
  count      = var.create_iam_codedeployrole == true ? 1 : 0
  role       = aws_iam_role.codedeploy_service[count.index].name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
}
