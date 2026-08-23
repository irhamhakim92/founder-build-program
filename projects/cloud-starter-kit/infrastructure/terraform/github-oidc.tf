locals {
  github_repository = "irhamhakim92/founder-build-program"

  github_oidc_subject = "repo:irhamhakim92/founder-build-program:pull_request"

  terraform_state_bucket = "fbp-terraform-state-213424233863-ap-southeast-1"
  terraform_state_key    = "cloud-starter-kit/dev/terraform.tfstate"
}

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com",
  ]

  tags = {
    Name = "${local.name_prefix}-github-oidc"
  }
}

data "aws_iam_policy_document" "github_actions_assume_role" {
  statement {
    sid    = "GitHubActionsAssumeRole"
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
        local.github_oidc_subject,
      ]
    }
  }
}

resource "aws_iam_role" "github_actions_plan" {
  name        = "${local.name_prefix}-github-plan-role"
  description = "Read-only role used by GitHub Actions to run Terraform plans."

  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json

  max_session_duration = 3600

  tags = {
    Name = "${local.name_prefix}-github-plan-role"
  }
}

data "aws_iam_policy_document" "github_actions_plan_permissions" {
  statement {
    sid    = "ReadEC2"
    effect = "Allow"

    actions = [
      "ec2:Describe*",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "ReadIAM"
    effect = "Allow"

    actions = [
      "iam:Get*",
      "iam:List*",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "ReadSSM"
    effect = "Allow"

    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "ListTerraformStateBucket"
    effect = "Allow"

    actions = [
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::${local.terraform_state_bucket}",
    ]

    condition {
      test     = "StringLike"
      variable = "s3:prefix"

      values = [
        "cloud-starter-kit/dev/*",
      ]
    }
  }

  statement {
    sid    = "ReadTerraformState"
    effect = "Allow"

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "arn:aws:s3:::${local.terraform_state_bucket}/${local.terraform_state_key}",
    ]
  }
}

resource "aws_iam_role_policy" "github_actions_plan" {
  name = "${local.name_prefix}-github-plan-policy"
  role = aws_iam_role.github_actions_plan.id

  policy = data.aws_iam_policy_document.github_actions_plan_permissions.json
}
