data "aws_ssm_parameter" "ubuntu_ami" {
  name = var.ubuntu_ami_parameter
}

resource "aws_instance" "web" {
  ami                         = data.aws_ssm_parameter.ubuntu_ami.value
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.web.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_ssm.name
  associate_public_ip_address = true

  user_data                   = file("${path.module}/user-data.sh")
  user_data_replace_on_change = true

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.root_volume_size
    encrypted             = true
    delete_on_termination = true
  }

  tags = {
    Name = "${local.name_prefix}-web-server"
    Role = "application-host"
  }

  lifecycle {
    precondition {
      condition     = var.root_volume_size >= 8
      error_message = "The EC2 root volume must be at least 8 GiB."
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.ssm_core
  ]
}
