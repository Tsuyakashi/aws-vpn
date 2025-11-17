provider "aws" {
    region = "eu-central-1"
}

data "aws_ami" "ubuntu" {
    most_recent = true

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
    }

    owners = ["099720109477"] # Canonical
}


resource "aws_instance" "app_server" {
    ami = data.aws_ami.ubuntu.id
    instance_type = var.instance_type
    # user_data = file("./start.sh")
    
    security_groups = [  
        "udp",
        "ssh"
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

resource "aws_security_group" "ssh" {
    name = "ssh"
        ingress {
            from_port = 22
            to_port = 22
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        }
}

resource "aws_security_group" "tcp" {
    name = "tcp"
        ingress {
            from_port = 0
            to_port = 65535
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