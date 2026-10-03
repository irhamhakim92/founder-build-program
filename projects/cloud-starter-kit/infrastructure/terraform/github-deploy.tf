locals {
  github_deploy_oidc_subject = "repo:${local.github_repository}:ref:refs/heads/main"
}

data "aws_iam_policy_document" "github_actions_deploy_assume_role" {
  statement {
    sid    = "GitHubActionsDeployAssumeRole"
    effect = "Allow"

    actions = [
      "sts:AssumeRoleWithWebIdentity",
    ]

    principals {
      type = "Federated"

      identifiers = [
        aws_iam_openid_connect_provider.github.arn,
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"

      values = [
        "sts.amazonaws.com",
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"

      values = [
        local.github_deploy_oidc_subject,
      ]
    }
  }
}

resource "aws_iam_role" "github_actions_deploy" {
  name        = "${local.name_prefix}-github-deploy-role"
  description = "Allows GitHub Actions on main to deploy the Cloud Starter Kit application through Systems Manager."

  assume_role_policy = data.aws_iam_policy_document.github_actions_deploy_assume_role.json

  max_session_duration = 3600

  tags = {
    Name = "${local.name_prefix}-github-deploy-role"
  }
}

data "aws_iam_policy_document" "github_actions_deploy_permissions" {
  statement {
    sid    = "DescribeDeploymentTarget"
    effect = "Allow"

    actions = [
      "ec2:DescribeInstances",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "SendDeploymentCommand"
    effect = "Allow"

    actions = [
      "ssm:SendCommand",
    ]

    resources = [
      aws_instance.web.arn,
      "arn:aws:ssm:${var.aws_region}::document/AWS-RunShellScript",
    ]
  }

  statement {
    sid    = "ReadDeploymentCommandResult"
    effect = "Allow"

    actions = [
      "ssm:GetCommandInvocation",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "github_actions_deploy" {
  name = "${local.name_prefix}-github-deploy-policy"
  role = aws_iam_role.github_actions_deploy.id

  policy = data.aws_iam_policy_document.github_actions_deploy_permissions.json
}
