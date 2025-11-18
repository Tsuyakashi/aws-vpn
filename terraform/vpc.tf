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