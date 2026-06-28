data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
  owners = ["099720109477"]
}

resource "aws_iam_role" "ssm_role" {
  name_prefix        = "vpn-ssm-role-"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "ssm_put_param" {
  role = aws_iam_role.ssm_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["ssm:PutParameter"]
      Resource = "arn:aws:ssm:*:*:parameter/vpn/*"
    }]
  })
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name_prefix = "vpn-ssm-profile-"
  role        = aws_iam_role.ssm_role.name
}

resource "aws_security_group" "wg" {
  name = "wireguard-sg"

  ingress {
    from_port   = var.wg_port
    to_port     = var.wg_port
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "vpn" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  iam_instance_profile        = aws_iam_instance_profile.ssm_profile.name
  vpc_security_group_ids      = [aws_security_group.wg.id]
  associate_public_ip_address = true

  user_data = templatefile("${path.module}/scripts/wireguard-init.sh.tpl", {
    wg_port     = var.wg_port
    region      = var.region
    client_name = "user-cfg"
  })

  tags = { Name = var.instance_name }
}
