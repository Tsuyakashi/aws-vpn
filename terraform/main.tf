provider "aws" {
    region = "eu-central-1"
}

resource "random_id" "suffix" {
  byte_length = 3
}

resource "aws_key_pair" "rsa_key" {
    key_name = "rsa-${var.instance_name}-${random_id.suffix.hex}"
    public_key = file("./keys/rsa.key.pub")
}

resource "aws_instance" "app_server" {
    ami = var.ami
    instance_type = var.instance_type
    key_name = aws_key_pair.rsa_key.key_name

    vpc_security_group_ids = [
        aws_security_group.udp.id,
        aws_security_group.tcp.id
    ]

    associate_public_ip_address = true
    
    tags = {
        Name = var.instance_name
    }
}

resource "aws_security_group" "udp" {
    name = "udp"
        ingress {
            from_port = 0
            to_port = 65535
            protocol = "udp"
            cidr_blocks = ["0.0.0.0/0"]
        }
        egress {
            from_port = 0
            to_port = 65535
            protocol = "udp"
            cidr_blocks = ["0.0.0.0/0"]
        }
}

resource "aws_security_group" "tcp" {
    name = "tcp"
        ingress {
            from_port = 22
            to_port = 22
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        }
        egress {
            from_port = 0
            to_port = 65535
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        }
}