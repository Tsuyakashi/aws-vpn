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

resource "aws_key_pair" "rsa_key" {
    key_name = "rsa.key.pub"
    public_key = file("./keys/rsa.key.pub")
}

resource "aws_instance" "app_server" {
    ami = data.aws_ami.ubuntu.id
    instance_type = var.instance_type
    key_name = aws_key_pair.rsa_key.key_name
    # user_data = file("./start.sh")
    
    security_groups = [  
        "udp",
        "ssh",
        "tcp"
    ]

    associate_public_ip_address = true
    
    tags = {
        Name = var.instance_name
    }
}
