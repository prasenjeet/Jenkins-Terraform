resource "aws_security_group" "this" {
  name        = "${var.project}-${var.environment}-ec2-sg"
  description = "Security group for ${var.project} EC2 instances (${var.environment})"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      description = ingress.value.description
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(var.tags, { Name = "${var.project}-${var.environment}-ec2-sg" })
}

resource "aws_instance" "this" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.this.id]
  key_name               = var.key_name != "" ? var.key_name : null

  root_block_device {
    volume_type           = var.root_volume_type
    volume_size           = var.root_volume_size
    delete_on_termination = true
    encrypted             = true
  }

  user_data = var.user_data

  monitoring = var.enable_detailed_monitoring

  metadata_options {
    http_tokens = "required"  # IMDSv2 only
  }

  tags = merge(var.tags, { Name = "${var.project}-${var.environment}-ec2" })

  lifecycle {
    ignore_changes = [ami]
  }
}

resource "aws_eip" "this" {
  count    = var.associate_public_ip ? 1 : 0
  instance = aws_instance.this.id
  domain   = "vpc"

  tags = merge(var.tags, { Name = "${var.project}-${var.environment}-eip" })
}
