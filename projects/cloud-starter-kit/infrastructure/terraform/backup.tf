data "aws_iam_policy_document" "dlm_assume_role" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "Service"

      identifiers = [
        "dlm.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_role" "dlm_backup" {
  name               = "${local.name_prefix}-dlm-backup-role"
  description        = "Allows AWS Data Lifecycle Manager to create and manage Cloud Starter Kit EBS snapshots."
  assume_role_policy = data.aws_iam_policy_document.dlm_assume_role.json

  tags = {
    Name = "${local.name_prefix}-dlm-backup-role"
  }
}

resource "aws_iam_role_policy_attachment" "dlm_backup" {
  role = aws_iam_role.dlm_backup.name

  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSDataLifecycleManagerServiceRole"
}

resource "aws_dlm_lifecycle_policy" "web_daily" {
  description        = "Daily EBS snapshots for the Cloud Starter Kit application host"
  execution_role_arn = aws_iam_role.dlm_backup.arn
  state              = "ENABLED"

  policy_details {
    policy_type        = "EBS_SNAPSHOT_MANAGEMENT"
    resource_types     = ["INSTANCE"]
    resource_locations = ["CLOUD"]

    target_tags = {
      Role = "application-host"
    }

    schedule {
      name = "Daily snapshots with 7-day retention"

      create_rule {
        interval      = 24
        interval_unit = "HOURS"
        times         = ["18:00"]
      }

      retain_rule {
        count = 7
      }

      copy_tags = true

      tags_to_add = {
        Backup = "daily-dlm"
      }
    }
  }

  tags = {
    Name = "${local.name_prefix}-daily-backup"
  }

  depends_on = [
    aws_iam_role_policy_attachment.dlm_backup,
  ]
}
